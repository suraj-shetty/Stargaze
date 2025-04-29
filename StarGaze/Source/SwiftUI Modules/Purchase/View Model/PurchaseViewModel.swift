//
//  PurchaseViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import StoreKit
import Combine

enum PurchaseState {
    case idle
    case inProgress
    case error(SGAPIError)
    case crediting
    case done
    case creditError(SGAPIError)
}

class PurchaseViewModel: ObservableObject {
    let product: Product
    let type: StoreCoinOptions
    
    @Published private(set) var state: PurchaseState = .idle
    @Published private(set) var transaction: CoinTransactionResponse? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(product: Product, type: StoreCoinOptions) {
        self.product = product
        self.type = type
    }
    
    
    deinit {
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
    
    func initiatePurchase() {
        
        switch state {
        case .idle:
            self.state = .inProgress
            
            let request = CoinTransactionRequest(coins: type.coins,
                                                 title: product.displayName,
                                                 desc: "\(type.coins)", //product.description
                                                 price: "\(product.price)",
                                                 discountedPrice: NSDecimalNumber(decimal: product.price).doubleValue)
            
            SGPaymentServices.initiateCoinsCreditTransaction(with: request)
                .sink {[weak self] result in
                    switch result {
                    case .finished: break
                    case .failure(let error):
                        self?.state = .error(error)
                    }
                } receiveValue: {[weak self] response in
                    self?.state = .inProgress
                    self?.transaction = response
                }
                .store(in: &cancellables)
            
        default:
            break
        }                        
    }
    
    func creditCoin(with transaction: StoreTransaction, completion: @escaping (CoinCreditResponse?, Error?) -> Void) {
                
        guard let current = self.transaction
        else {
            completion(nil, SGAPIError.emptyData)
            return
        }
        
        var metaData = [String: Any]()
        metaData["platform"] = "iOS"
        
        if let jsonData = try? JSONSerialization.jsonObject(with: transaction.jsonRepresentation) as? [String: Any],
           !jsonData.isEmpty {
            metaData.merge(jsonData) { current, _ in
                current
            }
        }
        
        
        let request = CoinCreditRequest(id: current.id,
                                        receipt: "",
                                        status: .paid,
                                        metadata: metaData,
                                        desc: "\(type.coins)")
        
        SGPaymentServices.creditCoins(with: request)
            .sink { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    completion(nil, error)
                }
            } receiveValue: { response in
                completion(response, nil)
            }
            .store(in: &cancellables)
    }
    
    func cancelTransaction(completion: @escaping (Bool, Error?) -> Void) {
        guard let current = self.transaction
        else {
            completion(false, SGAPIError.emptyData)
            return
        }
        
        var metaData = [String: Any]()
        metaData["platform"] = "iOS"
        
        let request = CoinCreditRequest(id: current.id,
                                        receipt: "",
                                        status: .failed,
                                        metadata: metaData,
                                        desc: "\(type.coins)")
        
        SGPaymentServices.failedCoinCredit(with: request)
            .sink { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    completion(false, error)
                }
            } receiveValue: { response in
                completion(response, nil)
            }
            .store(in: &cancellables)
    }
    
    func asyncCreditCoin(with transaction: StoreTransaction) async throws -> CoinCreditResponse {
        return try await withCheckedThrowingContinuation({
        (continuation: CheckedContinuation<CoinCreditResponse, Error>) in
            creditCoin(with: transaction) { response, error in
                if let response = response {
                    continuation.resume(returning: response)
                }
                else {
                    continuation.resume(throwing: error!)
                }
            }
        })
    }
    
    func asyncCancelTransaction() async throws -> Bool {
        return try await withCheckedThrowingContinuation({
        (continuation: CheckedContinuation<Bool, Error>) in
            
            cancelTransaction { didCancel, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume(returning: didCancel)
                }
            }                                    
        })
    }
}
