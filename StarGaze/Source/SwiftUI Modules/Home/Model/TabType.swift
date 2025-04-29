//
//  TabType.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum TabType: Int, CaseIterable {
    case feeds = 0
    case celebrities
    case events
    case menu
    
    var tabItem: TabItemData {
        switch self {
        case .feeds:
            return TabItemData(title: NSLocalizedString("TAB_TITLE_FEEDS", comment: ""),
                               image: "feeds_tab")
        case .celebrities:
            return TabItemData(title: NSLocalizedString("TAB_TITLE_STARS", comment: ""),
                               image: "stars_tab")
        case .events:
            return TabItemData(title: NSLocalizedString("TAB_TITLE_EVENTS", comment: ""),
                               image: "events_tab")
        case .menu:
            return TabItemData(title: NSLocalizedString("TAB_TITLE_MENU", comment: ""),
                               image: "menu_tab")
        }
    }
}
