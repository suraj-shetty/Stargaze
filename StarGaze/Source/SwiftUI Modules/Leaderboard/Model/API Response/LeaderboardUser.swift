//
//  LeaderboardUser.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct LeaderboardUser: Codable, Identifiable {
    let id: Int
    let name: String
    let me: String
    let picture: String?
    let rankString: String
    let coinsString: String
    
    var isMe: Bool {
        get {
            return me == "true"
        }
    }
    
    var rank: Int {
        get {
            return Int(rankString) ?? 0
        }
    }
    
    var coins: Int {
        get {
            return Int(coinsString) ?? 0
        }
    }
    
    var picURL: URL? {
        get {
            return URL(string: picture ?? "")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case name
        case me = "isMe"
        case picture
        case rankString = "rank"
        case coinsString = "coins"
    }
}
