//
//  BuyCoinsView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 29/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import StoreKit
import Shimmer
struct BuyCoinsView: View {
    
    @StateObject private var store = Store()
    @State private var loading: Bool = false
    
    @State private var productToPurchase: Product?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                
                ZStack {
                    HStack(spacing: 9) {
                        Text("buy.coins.title")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.text1)
                        Image("coin")
                    }
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .tint(.text1)
                                .frame(width: 49)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: 44)
                .background(Color.brand1)
                                
                switch store.state {
                case .idle, .loading:
                    VStack(spacing: 12) {
                        ForEach(0..<4) { _ in
                            BuyCoinRow(title: "Buy 100 Coins for Rs 500",
                                       subTitle: "Increases propability of winning by 2%",
                                       background: .gray)
                            .redacted(reason: .placeholder)
                            .shimmering()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                case .loaded(_):
                    if store.coins.isEmpty {
                        PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                              title: "iap.list.empty.title".localizedKey,
                                                              message: ""))
                        .listRowInsets(.init())
                        .listRowBackground(Color.brand1)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal, 20)
                    }
                    else {
                        List {
                            ForEach(store.coins) { product in
//                                ZStack {
//                                    
//                                    .buttonStyle(.plain)
//                                    .opacity(0)
//                                }
                                Button(action: {
                                    self.productToPurchase = product
                                }, label: {
                                    cell(for: product,
                                         type: type(for: product.id))
                                })
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.brand1)
                                
                            }
                        }
                        .listStyle(.plain)
                        .listRowInsets(.init(top: 0, leading: 20, bottom: 12, trailing: 20))
                        
                    }
                    
                case .failed(_):
                    PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                          title: "iap.list.fetch.error.title".localizedKey,
                                                          message: ""))
                    .listRowInsets(.init())
                    .listRowBackground(Color.brand1)
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, 25)
                }
    //
    //            Spacer()
            }
            .background(Color.brand1)
            .navigationBarHidden(true)
            .navigationDestination(for: $productToPurchase) { product in
                PaymentProcessingView(store: self.store,
                                      paymentViewModel: PurchaseViewModel(product: product,
                                                                          type: StoreCoinOptions(rawValue: product.id) ?? .coin100))
            }
        }
    }
    
    @ViewBuilder
    private func cell(for product: Product, type: StoreCoinOptions) -> some View {
        BuyCoinRow(title: "Buy \(type.coins) coins for \(product.localizedPrice())",
                   subTitle: "",
                   background: type.tileColor)
    }
    
    private func type(for value: String) -> StoreCoinOptions {
        let type = StoreCoinOptions.allCases.first(where: { $0.appstoreID == value }) ?? .coin100
        return type
    }
}

struct BuyCoinsView_Previews: PreviewProvider {
    static var previews: some View {
        BuyCoinsView()
    }
}

struct BuyCoinRow: View {
    let title: String
    let subTitle: String
    let background: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 3) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            if !subTitle.isEmpty {
                Text(subTitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
        .background(
            ZStack {
                background
                    .cornerRadius(11)
                
                HStack {
                    Circle()
                        .frame(width: 26, height: 26)
                        .padding(.leading, -17)
                        .foregroundColor(.brand1)
                    Spacer()
                    Circle()
                        .frame(width: 26, height: 26)
                        .padding(.trailing, -17)
                        .foregroundColor(.brand1)
                }
            }
        )
        
        /*
        ZStack {
            Text("")
                .frame(height: 105)
                .frame(maxWidth: .infinity)
                .background(background)
                .cornerRadius(11)
                .padding(.horizontal, 20)
            HStack {
                Circle()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 6)
                    .foregroundColor(.brand1)
                Spacer()
                Circle()
                    .frame(width: 26, height: 26)
                    .padding(.trailing, 6)
                    .foregroundColor(.brand1)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.walsheimMedium(size: 20))
                    .foregroundColor(.white)
                Text(subTitle)
                    .font(.walsheimRegular(size: 16))
                    .foregroundColor(.white)
            }
        }
         */
    }
}


extension Product {
    func localizedPrice() -> String {
        return NumberFormatter.currencyFormatter
            .string(from: NSDecimalNumber(decimal: self.price)) ?? ""
    }
}
