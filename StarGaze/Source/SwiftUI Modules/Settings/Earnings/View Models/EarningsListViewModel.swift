//
//  EarningsListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import Foundation


class EarningsListViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var error: SGAPIError? = nil
    @Published var didEnd: Bool = false
    
    @Published var amountText: String = " "
    @Published var transactions: [EarningsSectionInfo] = []
    
    @Published var range: EarningDateRangeType = .month
    
    private let apiClient = SGUserService()
    private let status: EarningStatus
    
    init(status: EarningStatus) {
        self.status = status
    }
    
    @MainActor
    func fetchTransactions() async {
//        if didEnd { return }
//        guard loading == false else { return }
        
//        self.range = range
        
        let request = EarningTransactionsRequest(start: range.startDate,
                                                 end: range.endDate,
                                                 status: status)
        
        self.loading = true
        
        let response = await apiClient.getMyEarnings(request: request)
        switch response {
        case .success(let success):
            let result = success.result
            let amount = NSDecimalNumber(floatLiteral: result.total)
            
            self.amountText = NumberFormatter.currencyFormatter.string(from: amount) ?? ""
            
            var transactions = result.transactions.sorted { lhs, rhs in
                return lhs.date > rhs.date
            }
            
            var sections = [EarningsSectionInfo]()
            
            while !transactions.isEmpty {
                guard let firstDate = transactions.first?.date
                else { continue }
                
                let sectionText = firstDate.toFormat("E d MMM yyyy")
                let subTransactions = transactions.filter { transaction in
                    let date = transaction.date
                    
                    return date.day == firstDate.day
                    && date.month == firstDate.month
                    && date.year == firstDate.year
                }
                                                    
                if !subTransactions.isEmpty {
                    transactions.removeAll(where: { subTransactions.contains($0) })

                    let sectionInfo = EarningsSectionInfo(title: sectionText,
                                                          rows: subTransactions.map({
                        EarningsRowInfo(transaction: $0)
                    })
                    )
                    sections.append(sectionInfo)
                }
            }
            
            self.transactions = sections
            self.didEnd = true
            
        case .failure(let failure):
            self.error = failure
            self.didEnd = true
        }
        
        self.loading = false
    }
}
