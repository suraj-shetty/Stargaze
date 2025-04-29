//
//  LeaderboardCategory.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct LeaderboardCategory: Codable {
    let id: Int
    let name: String
    let users: [LeaderboardUser]
    
    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case name = "categoryName"
        case users = "data"
    }
}
