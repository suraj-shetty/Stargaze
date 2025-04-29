//
//  MyWallet.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 15/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum TransactionType: String, Codable {
    case debit = "debit"
    case credit = "credit"
}

enum WalletCoinType: String, Codable {
    case gold = "GOLD"
    case silver = "SILVER"
}

enum ActivityType: String, Codable {
    case signup = "sign_up"
    case like = "like"
    case commentLike = "like_comment"
    case comment = "comment"
    case dailyLaunch = "daily_launch"
    case share = "share"
    case purchase = "purchase"
    case videoAd = "video_ad"
    case spent = "spent"
    case subscription = "purchase_celeb_subscription"
    case eventJoined = "join_event"
    case goldCoinPurchase = "PURCHASE_GOLD_COIN"
    case subscription2 = "PURCHASE_CLEB_SUBSCRIPTION"
    case unknown = "Unknown"
    
    init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        
        if let type = ActivityType(rawValue: label) {
            self = type
        }
        else {
            self = .unknown
        }
        
    }
//    case subscription = "celeb_purchase_subscription"
}

struct MyWalletTransaction: Codable {
    let date: String
    let coin: Int
    let coinType: WalletCoinType?
    let transactionType: TransactionType
    let activityType: ActivityType
    let createdAt: Date
    let desc: String?
    let refNum: Int
    
    enum CodingKeys: String, CodingKey {
        case date
        case coin
        case coinType
        case transactionType
        case activityType
        case createdAt
        case desc = "description"
        case refNum = "refrence_number"
    }
}

struct MyWalletResult: Codable {
    let result: [MyWalletTransaction]
    
    enum CodingKeys: String, CodingKey {
        case result = "coin_activity"
    }
}
