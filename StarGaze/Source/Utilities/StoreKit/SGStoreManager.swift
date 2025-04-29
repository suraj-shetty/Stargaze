//
//  SGStoreManager.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import StoreKit

typealias StoreTransaction = StoreKit.Transaction

public enum StoreError: Error {
    case failedVerification
    case pending
    case cancelled
}

class Store: LoadableObject {
    typealias Output = [Product]
    
    func load() {
        
    }
    
    @Published private(set) var coins: [Product] = []
    @Published private(set) var subscriptions: [Product]

    @Published private(set) var state: LoadingState<[Product]> = .idle
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    private let productIds: [String]
    private var pendingIds: [String]
    
    
    init() {
        productIds = StoreCoinOptions.allCases.map({ $0.appstoreID })
        pendingIds = []
        
        coins = []
        subscriptions = []
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await fetchProducts()            
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
    
    func isPurchased(_ product: Product) async throws -> Bool {
        //Determine whether the user purchases a given product.
        switch product.type {
//        case .nonRenewable:
//            return purchasedNonRenewableSubscriptions.contains(product)
//        case .nonConsumable:
//            return purchasedCars.contains(product)
        case .autoRenewable:
            return subscriptions.contains(product)
        default:
            return false
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        
        var purchasedSubscriptions: [Product] = []
        
        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .consumable:
                    print("Consumable product")
                    
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                    }
                    
                case .nonRenewable:
                    print("Non renewable")
                    break
                    
                case .nonConsumable:
                    print("Non Consumable")
                    
                default:
                    print("Unknown product. Type: \(transaction.productType). ID: \(transaction.productID)")
                }
            }
            catch {
                print()
            }
        }
        
        self.subscriptions = purchasedSubscriptions
    }
    
    
    @MainActor
    func fetchProducts() async {
        self.state = .loading
        do {
            
            print("Product IDs \(productIds)")
            
            let products = try await Product.products(for: productIds)
            
            print("Fetched product count \(products.count)")
            
            var coins = [Product]()
            var subscriptions = [Product]()
            
            for product in products {
                switch product.type {
                case .consumable: coins.append(product)
                case .autoRenewable: subscriptions.append(product)
                case .nonRenewable:
                    print("Received Non renewable product \(product.id)")
                    break
                    
                case .nonConsumable:
                    print("Received Non consumable product \(product.id)")
                    break
                    
                default:
                    print("Received unknown product \(product.id)")
                }
            }
            
            self.coins = coins
            self.subscriptions = subscriptions
            self.state = .loaded(coins)
        }
        catch {
            self.state = .failed(error)
//            print("Failed product request from the App Store server: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreTransaction {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            //Always finish a transaction.
            await transaction.finish()

            return transaction
            
        case .userCancelled:
            throw StoreError.cancelled
            
        case .pending:
            throw StoreError.pending
            
        @unknown default:
            print("Unknown result \(result)")
            throw StoreError.failedVerification
        }
    }
}
