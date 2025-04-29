//
//  SubscriptionPlanRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SubscriptionPlanRequest: Encodable {
    let celebID: Int
    
    enum CodingKeys: String, CodingKey {
        case celebID = "celebId"
    }
}
