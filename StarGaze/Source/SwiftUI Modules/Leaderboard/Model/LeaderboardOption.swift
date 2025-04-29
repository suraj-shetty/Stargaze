//
//  LeaderboardOption.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

enum LeaderboardOption: String, Codable {
    case allTime = "all_time"
    case today = "today"
    case month = "monthly"
    
    var title: String {
        switch self {
        case .allTime:
            return NSLocalizedString("leaderboard.option.all-time", comment: "")
        case .today:
            return NSLocalizedString("leaderboard.option.today", comment: "")            
        case .month:
            return NSLocalizedString("leaderboard.option.month", comment: "")
        }
    }
}
