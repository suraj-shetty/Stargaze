//
//  Earnings.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import Foundation

struct EarningsInfo: Codable {
    let shows: Double
    let videoCalls: Double
    let posts: Double
    let subscriptions: Double
    let pending: Double
    
    enum CodingKeys: String, CodingKey {
        case shows = "showEarnings"
        case videoCalls = "eventEarnings"
        case posts = "postEarnings"
        case subscriptions = "subscriptionEarnings"
        case pending = "pendingTotalEarnings"
    }
}

struct EarningsResult: Codable {
    let result: EarningsInfo
}


struct EarningTransaction: Codable, Equatable {
    let id:Int
    let title: String
    let status: EarningStatus
    let type: EarningType
    let amount: Double
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case status
        case type
        case amount
        case date = "lastUpdatedDate"
    }
    
    static func ==(lhs: EarningTransaction, rhs: EarningTransaction) -> Bool {
        return (lhs.id == rhs.id)
    }
}

struct EarningListInfo: Codable {
    let total: Double
    let transactions: [EarningTransaction]
    
    enum CodingKeys: String, CodingKey {
        case total = "totalEarnings"
        case transactions = "results"
    }
}

struct EarningListResult: Codable {
    let result: EarningListInfo
}
