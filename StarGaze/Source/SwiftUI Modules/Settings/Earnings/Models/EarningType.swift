//
//  EarningType.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 14/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import Foundation

enum EarningType: String, Codable {
    case event = "event"
    case show = "show"
    case subscription = "subscription"
    case feed = "post"
}

extension EarningType {
    var icon: String {
        switch self {
        case .event:
            return "earningVideoCalls"
        case .show:
            return "earningShows"
        case .subscription:
            return "earningSubscription"
        case .feed:
            return "earningPost"
        }
    }
    
    var title: String {
        switch self {
        case .event:
            return NSLocalizedString("earnings.video-call.title", comment: "")
        case .show:
            return NSLocalizedString("earnings.shows.title", comment: "")
        case .subscription:
            return NSLocalizedString("earnings.subscription.title", comment: "")
        case .feed:
            return NSLocalizedString("earnings.post-pay.title", comment: "")
        }
    }
}
