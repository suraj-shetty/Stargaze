//
//  EventWinner.swift
//  StarGaze
//
//  Created by Suraj Shetty on 14/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
enum CoinType: String {
    case regular = "regular"
    case gold = "GOLD"
}

struct EventWinnerInfo: Codable {
    let id: Int
    let name: String?
    let picture: String?
}

struct EventWinner: Codable, Identifiable, Equatable {
    
    let id: Int
    let eventId: Int
    let isWinner: Bool
    let coinType: String
    let coins: Int
    let probability: Double
    let user: EventWinnerInfo
    
    static func == (lhs: EventWinner, rhs: EventWinner) -> Bool {
        return lhs.id == rhs.id
    }
}
