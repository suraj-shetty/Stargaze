//
//  CoinTransactionResponse.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum CoinTransactionStatus: String, Codable {
    case pending = "pending"
}

struct CoinTransactionResponse: Codable {
    let id: Int
    let status: CoinTransactionStatus
    let userID: Int
    let purchaseID: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case status = "transactionStatus"
        case userID = "userId"
        case purchaseID = "purchaseId"
    }    
}

struct CoinTransactionResult: Codable {
    let result: CoinTransactionResponse
}
