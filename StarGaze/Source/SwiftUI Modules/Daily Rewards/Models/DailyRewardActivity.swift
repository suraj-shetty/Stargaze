//
//  DailyRewardActivity.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 09/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum DailyRewardType: String, Codable {
    case signup = "sign_up"
    case like = "like"
    case commentLike = "like_comment"
    case comment = "comment"
    case dailyLaunch = "daily_launch"
    case share = "share"
    case purchase = "purchase"
    case videoAd = "video_ad"
    case spent = "spent"
    case subscription = "subscription"
}

struct DailyReward: Codable {
    let type: DailyRewardType
    let coins: Int
    
    enum CodingKeys: String, CodingKey {
        case type = "activityType"
        case coins = "coins"
    }
}

extension DailyReward: Identifiable {
    var id: String {
        return type.rawValue
    }    
}


struct DailyRewardResult: Codable {
    let result:[DailyReward]
}

extension DailyRewardType {
    var title: String {
        switch self {
        case .signup:
            return "Signup"
        case .like:
            return "Likes"
        case .commentLike:
            return "Likes on your comments"
        case .comment:
            return "Comments"
        case .dailyLaunch:
            return "Daily app launches"
        case .share:
            return "Shares"
        case .purchase:
            return "Purchases"
        case .videoAd:
            return "Watching videos"
        case .spent:
            return "Spending"
        case .subscription:
            return "Subscriptions"
        }
    }
    
    var iconName: String {
        switch self {
        case .signup:
            return "launchReward"
        case .like:
            return "rewardlike"
        case .commentLike:
            return "rewardComment"
        case .comment:
            return "rewardComment"
        case .dailyLaunch:
            return "launchReward"
        case .share:
            return "rewardShare"
        case .purchase:
            return "launchReward"
        case .videoAd:
            return "rewardVideo"
        case .spent:
            return "rewardVideo"
        case .subscription:
            return "rewardVideo"
        }
    }
}
