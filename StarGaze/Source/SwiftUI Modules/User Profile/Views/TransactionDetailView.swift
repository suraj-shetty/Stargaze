//
//  TransactionDetailView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 15/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: WalletTransactionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center,
               spacing: 0) {
            navView()
            headerView()
            infoView()
            Spacer()
        }
               .background {
                   Color.brand1
                       .ignoresSafeArea()
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
            
            if transaction.coinType == .gold {
                HStack(alignment: .center, spacing: 6) {
                    Text("wallet-detail.gold-coins.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 18, weight: .medium))
                    
                    Image("goldCoin")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            else {
                HStack(alignment: .center, spacing: 6) {
                    Text("wallet-detail.silver-coins.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 18, weight: .medium))
                    
                    Image("silverCoin")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            
            
            Spacer()
            
            Color.clear
                .frame(width: 49, height: 44) //To center align the title
        }
        .background {
            Color.walletContentBackground
                .ignoresSafeArea(.all, edges: .top)
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Spacer()
            
            VStack(alignment: .center,
                   spacing: 0) {
                if transaction.type == .credit {
                    Image("creditDetail")
                    
                    Text("+\(transaction.coins)")
                        .foregroundColor(.greenBlue)
                        .font(.system(size: 26, weight: .medium))
                        .padding(.top, 19)
                        .padding(.bottom, 9)
                }
                else {
                    Image("debitDetail")
                    
                    Text("-\(transaction.coins)")
                        .foregroundColor(.text1)
                        .font(.system(size: 26, weight: .medium))
                        .padding(.top, 19)
                        .padding(.bottom, 9)
                }
                
                Text(transaction.detailTitle)
                    .foregroundColor(.text1)
                    .font(.system(size: 18, weight: .bold))
                
                Text(transaction.detailDateText.uppercased())
                    .foregroundColor(.text2)
                    .font(.system(size: 12, weight: .regular))
                    .kerning(1.71)
                    .opacity(0.3)
                    .padding(.top, 12)
            }
                   .padding(.init(top: 13,
                                  leading: 20,
                                  bottom: 26,
                                  trailing: 20))
            
            Spacer()
        }
        .background {
            Color.walletContentBackground
                .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
            
        }
    }
    
    private func infoView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                if transaction.coinType == .gold {
                    if transaction.type == .debit {
                        Text("Debit gold coins")
                            .foregroundColor(.text2)
                            .font(.system(size: 18, weight: .regular))
                            .opacity(0.5)
                    }
                    else {
                        Text("Credit gold coins")
                            .foregroundColor(.text2)
                            .font(.system(size: 18, weight: .regular))
                            .opacity(0.5)
                    }
                    
                    HStack(spacing: 4) {
                        Image("goldCoin")
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Text("\(transaction.coins)")
                            .foregroundColor(.text1)
                            .font(.system(size: 16, weight: .regular))
                        
                        Spacer()
                    }
                    .padding(.top, 13)
                    
                    Text(transaction.type == .debit ? "Spent on" : "Amount")
                        .foregroundColor(.text2)
                        .font(.system(size: 18, weight: .regular))
                        .opacity(0.5)
                        .padding(.top, 27)
                    
                    Text(transaction.desc)
                        .foregroundColor(.text1)
                        .font(.system(size: 16, weight: .regular))
                        .padding(.top, 10)
                    
                }
                else {
                    if transaction.type == .debit {
                        Text("Debit silver coins")
                            .foregroundColor(.text2)
                            .font(.system(size: 18, weight: .regular))
                            .opacity(0.5)
                    }
                    else {
                        Text("Earned silver coins")
                            .foregroundColor(.text2)
                            .font(.system(size: 18, weight: .regular))
                            .opacity(0.5)
                    }
                    
                    HStack(spacing: 4) {
                        Image("silverCoin")
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Text("\(transaction.coins)")
                            .foregroundColor(.text1)
                            .font(.system(size: 16, weight: .regular))
                        
                        Spacer()
                    }
                    .padding(.top, 13)
                    
                    Text(transaction.type == .debit ? "Spend on" : "Based on")
                        .foregroundColor(.text2)
                        .font(.system(size: 18, weight: .regular))
                        .opacity(0.5)
                        .padding(.top, 27)
                    
                    Text(transaction.desc)
                        .foregroundColor(.text1)
                        .font(.system(size: 16, weight: .regular))
                        .padding(.top, 10)
                }
                
                Divider()
                    .foregroundColor(.text1)
                    .opacity(0.4)
                    .padding(.vertical, 19)
                    .padding(.horizontal, -20)
                
                Text("Reference number")
                    .foregroundColor(.text2)
                    .font(.system(size: 18, weight: .regular))
                    .opacity(0.5)
                
                Text(String(transaction.ref))
                    .foregroundColor(.text1)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.top, 10)

            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background {
            Color.walletContentBackground
                .cornerRadius(15)
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
}

struct TransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailView(transaction: WalletTransactionViewModel(type: .credit,
                                                                      title: "Debit Silver Coins",
                                                                      date: Date(),
                                                                      dateText: "13 September 2022, 03:35 PM",
                                                                      timeText: "3:35 PM",
                                                                      coinType: .gold,
                                                                      coins: 70,
                                                                      detailTitle: "Debit 150 Silver Coins",
                                                                      detailDateText: "13 September 2022, 03:35 PM",
                                                                      desc: "Redeem coins on virtal kohli video call",
                                                                     ref: 1010))
    }
}
