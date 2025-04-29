//
//  CelebSubscriptionRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct CelebSubscriptionRequest: Encodable {
    let celebID: Int
    let typeID: Int
    let autoRenew: Bool
    let desc: String
    
    enum CodingKeys: String, CodingKey {
        case celebID = "celebId"
        case typeID = "typeId"
        case autoRenew
        case desc = "description"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(celebID)", forKey: .celebID)
        try container.encode("\(typeID)", forKey: .typeID)
        try container.encode(autoRenew, forKey: .autoRenew)
        try container.encode(desc, forKey: .desc)
    }
}
