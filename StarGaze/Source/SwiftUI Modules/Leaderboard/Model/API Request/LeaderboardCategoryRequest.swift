//
//  LeaderboardCategoryRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct LeaderboardCategoryRequest: Codable {
    let type: LeaderboardOption
    let start: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case type = "leaderboardType"
        case start = "start"
        case pageSize = "length"
    }
}
