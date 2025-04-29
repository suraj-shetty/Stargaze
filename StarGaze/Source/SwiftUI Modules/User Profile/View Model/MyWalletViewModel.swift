//
//  MyWalletViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 15/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftDate

struct WalletTransactionViewModel: Hashable, Identifiable {
    let id: UUID = UUID()
    let type: TransactionType
    let title: String
    let date: Date
    let dateText: String
    let timeText: String
    let coinType: WalletCoinType
    let coins: Int
    let detailTitle: String
    let detailDateText: String
    let desc: String
    let ref: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ref)
//        hasher.combine(title)
//        hasher.combine(dateText)
//        hasher.combine(timeText)
//        hasher.combine(coins)
    }
}

struct WalletTransactionGroup {
    let title: String
    let transactions: [WalletTransactionViewModel]
}

class MYWalletViewModel: ObservableObject {
    @Published var goldCoins: Int = 0
    @Published var silverCoins: Int = 0
    
    @Published var transactions:[WalletTransactionGroup] = []
    @Published var loading: Bool = false
    @Published var didEnd: Bool = false
    @Published var error: SGAPIError? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        SGAppSession.shared.wallet
            .sink {[weak self] wallet in
                self?.goldCoins = wallet?.goldCoins ?? 0
                self?.silverCoins = wallet?.silverCoins ?? 0
            }
            .store(in: &cancellables)
    }
    
    
    func getTransactions() {
        if loading || didEnd {
            return
        }
        
        loading = true
        SGWalletService.getTransations()
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    self?.error = error
                    self?.didEnd = true
                    self?.loading = false
                }
            } receiveValue: {[weak self] result in
                self?.loading = false
                self?.didEnd = true
                self?.updatedTransactions(with: result)
                
            }
            .store(in: &cancellables)

    }
    
    func refresh() {
        cancellables.forEach({ $0.cancel() })
        
        loading = false
        didEnd = false
        getTransactions()
    }
    
    private func updatedTransactions(with result: MyWalletResult) {
        let sorted = result.result.sorted { lhs, rhs in
            return lhs.createdAt > rhs.createdAt
        }
        
        let list = sorted.map { record in
            var title = ""
            var detailTitle = ""
            var desc = ""
            
            if record.coinType == .gold {
                if record.transactionType == .credit {
                    title = "Credit Gold Coins"
                    
                    if record.coin == 1 {
                        detailTitle = "Credit \(record.coin) Gold Coin"
                    }
                    else {
                        detailTitle = "Credit \(record.coin) Gold Coins"
                    }
                    desc = "\(record.coin)"
                }
                else {
                    title = "Debit Gold Coins"
                    desc = "Purchased Membership"
                    if record.coin == 1 {
                        detailTitle = "Debit \(record.coin) Gold Coin"
                    }
                    else {
                        detailTitle = "Debit \(record.coin) Gold Coins"
                    }
                    
                    if let recordDesc = record.desc, !recordDesc.isEmpty {
                        desc = recordDesc
                    }
                    else {
                        switch record.activityType {
                        case .subscription: desc = "Membership is purchased"
                        case .spent, .eventJoined: desc = "Celebrity Video Call"
                        default: desc = record.desc ?? ""
                        }
                    }
                }
            }
            else {
                if record.transactionType == .credit {
                    title = "Earned Silver Coins"
                    
                    if record.coin == 1 {
                        detailTitle = "Earned \(record.coin) Silver Coin"
                    }
                    else {
                        detailTitle = "Earned \(record.coin) Silver Coins"
                    }
                    
                    if let recordDesc = record.desc, !recordDesc.isEmpty {
                        desc = recordDesc
                    }
                    else {
                        switch record.activityType {
                        case .signup: desc = "Sign Up"
                        case .like: desc = "Like"
                        case .commentLike: desc = "Like on your comments"
                        case .comment: desc = "Comment"
                        case .dailyLaunch: desc = "Daily app launches"
                        case .share: desc = "Content Shares"
                        case .purchase: desc = "Purchases"
                        case .videoAd: desc = "Watching videos"
                        default: break
                        }
                    }
                }
                else {
                    title = "Debit Silver Coins"
                    
                    if record.coin == 1 {
                        detailTitle = "Debit \(record.coin) Silver Coin"
                    }
                    else {
                        detailTitle = "Debit \(record.coin) Silver Coins"
                    }
                    
                    if let recordDesc = record.desc, !recordDesc.isEmpty {
                        desc = recordDesc
                    }
                    else {
                        switch record.activityType {
                        case .spent: desc = "Spent"
                        case .eventJoined: desc = "Celebrity Video Call"
                        default: break
                        }
                    }
                }
                
            }
            
            let date = record.createdAt
            let convertedDate = date.convertTo(region: .current)
            let timeText = convertedDate.convertTo(region: .current).toFormat("h:mm a")
            var dateText = ""
            var detailDateText = ""
                        
            if convertedDate.isToday {
                dateText = "Today"
                detailDateText = "\(dateText), \(timeText)"
            }
            else {
                dateText = convertedDate.toFormat("dd MMM")
                detailDateText = "\(convertedDate.toFormat("dd MMMM yyyy")), \(timeText)"
            }
            
            let transaction = WalletTransactionViewModel(type: record.transactionType,
                                                         title: title,
                                                         date: convertedDate.date,
                                                         dateText: dateText,
                                                         timeText: timeText,
                                                         coinType: record.coinType ?? .silver,
                                                         coins: record.coin,
                                                         detailTitle: detailTitle,
                                                         detailDateText: detailDateText,
                                                         desc: desc,
                                                         ref: record.refNum)
            return transaction
        }
        
        let groupDictionary = Dictionary(grouping: list, by: { $0.dateText})
        let group = groupDictionary.map { (key: String, value: [WalletTransactionViewModel]) in
            return WalletTransactionGroup(title: key,
                                          transactions: value)
        }
            .sorted { lhs, rhs in
                return lhs.transactions.first!.date > rhs.transactions.first!.date
            }
        
        self.transactions.removeAll()
        self.transactions.append(contentsOf: group)
    }
}
