//
//  SideMenuItem.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

enum SideMenuType: Int, CaseIterable {
    case home
    case profile
    case notifications
//    case messages
    case leaderboard
//    case eventHistory
    case earnings
    case settings
    case logout
    
    var title: LocalizedStringKey {
        switch self {
        case .home:
            return "menu.home".localizedKey
        case .profile:
            return "menu.profile".localizedKey
        case .notifications:
            return "menu.notifications".localizedKey
//        case .messages:
//            return "menu.messages".localizedKey
        case .leaderboard:
            return "menu.leaderboard".localizedKey
//        case .eventHistory:
//            return "menu.event.history".localizedKey
        case .earnings:
            return "menu.earnings".localizedKey
        case .settings:
            return "menu.settings".localizedKey
        case .logout:
            return "menu.logout".localizedKey
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "menuHome"
        case .profile:
            return "menuProfile"
        case .notifications:
            return "menuNotification"
//        case .messages:
//            return "menuNotification"
        case .leaderboard:
            return "menuLeaderboard"
//        case .eventHistory:
//            return "menuHistory"
        case .earnings:
            return "menuEarnings"
        case .settings:
            return "menuSettings"
        case .logout:
            return "menuLogout"
        }
    }
}


struct SideMenuItem {
    let type: SideMenuType
    let vc: UIViewController
    
    init(type: SideMenuType, content: UIViewController) {
        self.type = type
        self.vc = content
    }
}
