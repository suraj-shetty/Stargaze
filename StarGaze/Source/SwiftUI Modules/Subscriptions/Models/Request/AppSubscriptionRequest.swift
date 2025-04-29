//
//  AppSubscriptionRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum AppSubscriptionType: String, Codable {
    case comment = "COMMENT"
    case appUnlock = "ALL_APP"
}

struct AppSubScriptionRequest: Encodable {
    let type: AppSubscriptionType
    let duration: SubscriptionPackageType
    let coin: Int
    let desc: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case duration = "subscriptionType"
        case coin
        case desc = "description"
    }
}
