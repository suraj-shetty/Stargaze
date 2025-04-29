//
//  MyWalletView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 11/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import KMBFormatter
import ToastUI
struct MyWalletView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MYWalletViewModel()
    
    @State private var buyCoins: Bool = false
    @State private var showSilverCoinsDetail: Bool = false
    @State private var pickedTransaction: WalletTransactionViewModel?
    
    var body: some View {
        VStack(spacing: 0) {
            navView()
            balanceView()
            
            Spacer()
            
            ZStack {
                if viewModel.loading {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            
                            ProgressView()
                                .tint(.text1)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
                else if viewModel.transactions.isEmpty {
                    PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                          title: "No records found",
                                                          message: ""))
                }
                else {
                    List {
                        ForEach(viewModel.transactions, id:\.title) { group in
                            Section {
                                ForEach(group.transactions) { transaction in
                                    MyWalletCellView(viewModel: transaction)
                                        .listRowInsets(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
                                        .listRowBackground(Color.walletContentBackground)
                                        .listRowSeparator(.hidden)
                                        .onTapGesture {
                                            self.pickedTransaction = transaction
                                        }
                                }
                            } header: {
                                HStack {
                                    Text(group.title)
                                        .foregroundColor(.text1)
                                        .font(.system(size: 22, weight: .regular))
                                        .padding(.init(top: 10,
                                                       leading: 20,
                                                       bottom: 3,
                                                       trailing: 20))
                                    
                                    Spacer()
                                }
                                .background {
                                    Color.walletContentBackground
                                }
                            }
                            .background(content: {
                                Color.walletContentBackground
                            })
                            .listSectionSeparator(.hidden)
                            .listRowBackground(Color.walletContentBackground)
                            .listRowInsets(.init())
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background {
                Color.walletContentBackground
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .cornerRadius(15, corners: [.topLeft, .topRight])
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
        .onAppear(perform: {
            viewModel.getTransactions()
        })
        .toast(item: $viewModel.error,
               dismissAfter: 3) {
        } content: { error in
            SGErrorToastView(message: error.localizedDescription)
        }
        .toastDimmedBackground(false)
        .fullScreenCover(isPresented: $buyCoins) {
            BuyCoinsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .exitPayment)) { notification in
            let userInfo = notification.userInfo
            
            if let paymentMade = userInfo?[NotificationUserInfoKey.paymentSuccess] as? Bool,
                paymentMade == true {
                viewModel.refresh()
            }
            
            self.buyCoins = false
        }
        .fullScreenCover(isPresented: $showSilverCoinsDetail) {
            EarnCoinsView()
        }
        .fullScreenCover(item: $pickedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
    
    private func navView() -> some View {
        HStack(alignment: .center) {
            Button {
                dismiss()
            } label: {
                Image("navBack")
                    .tint(.text1)
                    .frame(width: 49, height: 44)
            }
            
            Spacer()
            
            Text("wallet.list.title")
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Color.clear
                .frame(width: 49, height: 44) //To center align the title
        }
    }
    
    private func balanceView() -> some View {
        HStack(alignment: .center, spacing: 20) {
            goldCoinsBalanceView()
                .frame(height: 229)
            
            silverCoinsBalanceView()
                .frame(height: 229)
        }
        .padding(.init(top: 20,
                       leading: 20,
                       bottom: 30,
                       trailing: 20))
        
        
//        .listRowBackground(Color.brand1)
//        .listRowInsets(.init(top: 20,
//                             leading: 20,
//                             bottom: 30,
//                             trailing: 20))
    }
    
    private func goldCoinsBalanceView() -> some View {
        VStack(alignment:.leading,
               spacing: 12) {
            Text("wallet.tile.title")
                .foregroundColor(.walletBalanceTitle)
                .font(.system(size: 13,
                              weight: .regular))
            
            HStack(spacing: 8) {
                Image("goldCoin")
                
                Text(KMBFormatter.shared.string(fromNumber: Int64(viewModel.goldCoins)))
                    .foregroundColor(.walletBalanceTitle)
                    .font(.system(size: 30, weight: .medium))
                
//                Spacer()
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 0) {
                Text("profile.coins.gold") //arrowUp
                    .foregroundColor(.gold)
                    .font(.system(size: 16,
                                  weight: .regular))
                
                Spacer()
                
                Image("arrowUp")
                    .renderingMode(.template)
                    .tint(.walletBalanceTitle)
                    .rotationEffect(.radians(.pi/2))
            }
        }
        .padding(.init(top: 21,
                       leading: 19,
                       bottom: 22,
                       trailing: 19))
        .background(content: {
            ZStack {
                Color.walletTileBackground
                Image("walletTileBg")
                    .resizable(resizingMode: .tile)
                    .offset(x: 63, y: 0)
            }
            .cornerRadius(20)
        })
        .onTapGesture {
            self.buyCoins = true
        }
    }
    
    private func silverCoinsBalanceView() -> some View {
        VStack(alignment:.leading,
               spacing: 12) {
            Text("wallet.tile.title")
                .foregroundColor(.walletBalanceTitle)
                .font(.system(size: 13,
                              weight: .regular))
            
            HStack(spacing: 8) {
                Image("silverCoin")
                
                Text(KMBFormatter.shared.string(fromNumber: Int64(viewModel.silverCoins)))
                    .foregroundColor(.walletBalanceTitle)
                    .font(.system(size: 30, weight: .medium))
                
//                Spacer()
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 0) {
                Text("profile.coins.silver")
                    .foregroundColor(.text2)
                    .font(.system(size: 16,
                                  weight: .regular))
                
                Spacer()
                
                Image("arrowUp")
                    .renderingMode(.template)
                    .tint(.walletBalanceTitle)
                    .rotationEffect(.radians(.pi/2))
            }
        }
        .padding(.init(top: 21,
                       leading: 19,
                       bottom: 22,
                       trailing: 19))
        .background(content: {
            ZStack {
                Color.walletTileBackground
                Image("walletTileBg")
                    .opacity(0.6)
//                    .resizable(resizingMode: .tile)
                    .offset(x: 26, y: 156)
            }
        })
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            self.showSilverCoinsDetail = true
        }
    }
}

struct MyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        MyWalletView()
    }
}


struct MyWalletCellView: View {
    var viewModel: WalletTransactionViewModel
    
    var body: some View {
        HStack(alignment: .center,
               spacing: 10) {
            Image(viewModel.type == .credit ? "credit" : "debit")
            
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.title)
                    .foregroundColor(.text1)
                    .font(.system(size: 18, weight: .medium))
                    .frame(height: 20)
                
                Text(viewModel.timeText)
                    .foregroundColor(.text2)
                    .font(.system(size: 16, weight: .regular))
                    .frame(height: 22)
                    .opacity(0.29)
            }
            .fixedSize(horizontal: false, vertical: false)
            
            Spacer()
            
            if viewModel.type == .debit {
                Text("-\(viewModel.coins)")
                    .foregroundColor(.silver)
                    .font(.system(size: 18, weight: .medium))
                    .opacity(0.68)
            }
            else {
                Text("+\(viewModel.coins)")
                    .foregroundColor(.greenBlue)
                    .font(.system(size: 18, weight: .medium))
            }
        }
    }
    
    
}
