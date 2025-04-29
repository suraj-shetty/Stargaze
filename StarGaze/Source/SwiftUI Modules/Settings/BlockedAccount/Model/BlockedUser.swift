//
//  BlockedUser.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 08/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

class BlockedUser : Decodable {
    let id: Int
    let name: String
    let picture: String
    let followersCount: UInt64
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case picture
        case stats = "userStat"
    }
    
    enum UserCodingKeys: String, CodingKey {
        case user
    }
    
    enum StatsCodingKeys: String, CodingKey {
        case followersCount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserCodingKeys.self)
        let user = try container.nestedContainer(keyedBy: CodingKeys.self,
                                                 forKey: .user)
        let stats = try user.nestedContainer(keyedBy: StatsCodingKeys.self,
                                             forKey: .stats)
        
        id              = try user.decode(Int.self, forKey: .id)
        name            = try user.decode(String.self, forKey: .name)
        picture         = try user.decode(String.self, forKey: .picture)
        followersCount  = try stats.decode(UInt64.self, forKey: .followersCount)
    }
}

struct BlockedUserResult: Decodable {
    let result: [BlockedUser]
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}

