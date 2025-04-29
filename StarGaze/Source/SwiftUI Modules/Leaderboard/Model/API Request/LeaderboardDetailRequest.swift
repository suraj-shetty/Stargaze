//
//  LeaderboardDetailRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct LeaderboardDetailRequest : Codable {
    let id: Int
    let filter: LeaderboardOption
    let start: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case start
        case pageSize = "length"
        case filter = "leaderboardType"
    }
}
