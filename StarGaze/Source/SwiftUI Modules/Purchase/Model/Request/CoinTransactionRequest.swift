//
//  CoinTransactionRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct CoinTransactionRequest: Codable {
    let coins: Int
    let title: String
    let desc: String
    let price: String
    let discountedPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case coins
        case title
        case desc = "description"
        case price
        case discountedPrice
    }
}
