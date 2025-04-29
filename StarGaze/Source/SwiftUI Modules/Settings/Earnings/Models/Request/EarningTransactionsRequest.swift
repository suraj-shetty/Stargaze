//
//  EarningTransactionsRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 18/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import Foundation

struct EarningTransactionsRequest: Encodable {
    let start: String
    let end: String
    let status: EarningStatus
    
    enum CodingKeys: String, CodingKey {
        case start = "from"
        case end = "to"
        case status
    }
}
