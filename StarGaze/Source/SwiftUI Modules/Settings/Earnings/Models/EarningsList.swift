//
//  EarningsList.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import Foundation
import SwiftDate

struct EarningsSectionInfo {
    let title: String
    let rows: [EarningsRowInfo]
}

struct EarningsRowInfo {
    let id: Int
    let title: String
    let status: EarningStatus
    let type: EarningType
    let dateText: String
    let amountText: String
    
    init(transaction: EarningTransaction) {
        self.id     = transaction.id
        self.title  = transaction.title
        self.status = transaction.status
        self.type   = transaction.type
        
        let number = NSDecimalNumber(floatLiteral: transaction.amount)
        
        self.dateText = transaction.date.toFormat("E, d MMM yyyy - HH:mm")
        self.amountText = NumberFormatter.currencyFormatter.string(from: number) ?? ""
    }
}
