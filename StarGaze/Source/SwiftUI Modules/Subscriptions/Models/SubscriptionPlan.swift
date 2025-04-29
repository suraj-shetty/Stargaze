//
//  SubscriptionPlan.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SubscriptionPlan: Codable {
    let type: SubscriptionTypes
    let packages:[SubscriptionPackage]?
    
    enum CodingKeys: String, CodingKey {
        case type = "planType"
        case packages = "packages"
    }
}

struct SubscriptionPackage: Codable {
    let id: Int
    let type: SubscriptionPackageType
    let celebID: String
    let charges: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case celebID = "celebId"
        case charges
    }
}

struct SubscriptionPlanResult: Codable {
    let result: [SubscriptionPlan]
}
