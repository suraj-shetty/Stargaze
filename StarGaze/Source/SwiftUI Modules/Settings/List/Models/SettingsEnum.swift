//
//  SettingsEnum.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 10/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SettingsType: Identifiable {
    var id: Self { self }
    
    case notifications
    case blockedAccounts
    case about
    case faq
    case terms
    case deleteAccount
}

struct SettingsSectionInfo: Hashable {
    let title:String
    let option: [SettingsType]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

extension SettingsType {
    var title: String {
        switch self {
        case .notifications:
            return "Notification Settings"
        case .blockedAccounts:
            return "Blocked Accounts"
        case .about:
            return "About Stargaze"
        case .faq:
            return "FAQ's"
        case .terms:
            return "Terms & Conditions"
        case .deleteAccount:
            return "Delete Account"
        }
    }
    
    var iconName: String {
        switch self {
        case .notifications:
            return "pushNotification"
        case .blockedAccounts:
            return "blockedAccount"
        case .about:
            return "aboutIcon"
        case .faq:
            return "faq"
        case .terms:
            return "termsIcon"
        case .deleteAccount:
            return "trash"
        }
    }
}
