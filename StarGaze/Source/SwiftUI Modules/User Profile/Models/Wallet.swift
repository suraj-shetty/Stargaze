//
//  Wallet.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct WalletResult: Codable {
    let result: Wallet
}

struct Wallet: Codable {
    let wildCoins: Int
    var goldCoins: Int?
    var silverCoins: Int
    
    enum CodingKeys: String, CodingKey {
        case silverCoins = "totalCoinBalance"
        case wildCoins = "wildCoin"
        case goldCoins = "purchasedCoin"
    }
}
