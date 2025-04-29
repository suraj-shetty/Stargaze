//
//  EarnCoins.swift
//  StarGaze
//
//  Created by Suraj Shetty on 16/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

enum EarnCoinTypes: Int, CaseIterable {
    case onboard
    case dailyLaunch
    case share
    case comment
    case like
}

extension EarnCoinTypes {
    var descKey: LocalizedStringKey {
        switch self {
        case .onboard:
            return "earn.coins.signup.desc".localizedKey
        case .dailyLaunch:
            return "earn.coins.dailyLaunch.desc".localizedKey
        case .share:
            return "earn.coins.share.desc".localizedKey
        case .comment:
            return "earn.coins.comment.desc".localizedKey
        case .like:
            return "earn.coins.like.desc".localizedKey
        }
    }
}
