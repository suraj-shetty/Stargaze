//
//  SubscriptionEnums.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 19/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SubscriptionTypes: String, Codable, CaseIterable {
    case comments = "ALL_APP_COMMENT"
    case celebrity = "CELEB"
    case appUnlock = "APP_UNLOCK"
}

enum SubscriptionPackageType: String, Codable {
    case month = "1month"
    case quater = "quater"
    case halfYear = "half_year"
    case year = "year"
}

extension SubscriptionPackageType {
    var duration: Int { //In months
        switch self {
        case .month:
            return 1
        case .quater:
            return 3
        case .halfYear:
            return 6
        case .year:
            return 12
        }
    }
}

enum ActiveSubscriptionType: String, Codable {
    case appUnlock = "APP_UNLOCK"
    case comment = "ALL_APP_COMMENT_SUB"
    case celebrity = "CELEBRITY_SUB"
}
