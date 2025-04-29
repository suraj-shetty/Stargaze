//
//  FollowResponse.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct FollowResult: Codable {
    var followersCount:Int
    var didFollow:Bool
    
    enum CodingKeys : String, CodingKey {
        case followersCount
        case didFollow = "isFollowed"
    }
}

struct FollowResponse: Codable {
    var result: FollowResult
}
