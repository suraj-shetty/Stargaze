//
//  CoinCreditResponse.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct CoinCreditResponse: Codable {
    let id: Int
    let goldCoins: Int
    let silverCoins: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case goldCoins = "purchasedCoin"
        case silverCoins = "totalCoinEarned"
    }
}

struct CoinCreditResult: Codable {
    let result: CoinCreditResponse
}
