//
//  SubscriptionItem.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 01/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SubscriptionItem: Decodable {
    let id: Int
    let expiryAt: Date
    let packageType: SubscriptionPackageType
    let type: ActiveSubscriptionType
    let celeb: Celeb?
    
    enum CodingKeys: String, CodingKey {
        case id
        case expiryAt
        case packageType = "subscriptionType"
        case celeb
        case type = "type"
    }
}

struct SubscriptionItemList: Decodable {
    let result: [SubscriptionItem]
}
