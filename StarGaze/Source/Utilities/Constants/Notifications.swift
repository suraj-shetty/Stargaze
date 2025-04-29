//
//  Notifications.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let feedPosted   = Notification.Name("Feed Posted")
    static let tabSwitched  = Notification.Name("Tab Switched")
    static let menuWillShow = Notification.Name("Menu Will Show")
    static let menuDidHide  = Notification.Name("Menu Did Hide")
    static let feedListUpdated = Notification.Name("Feed List Update")
    static let profileUpdated = Notification.Name("User Profile Updated")
    static let packageAdded = Notification.Name("Package Added")
    static let exitPayment = Notification.Name("Exit payment")
    static let subscriptionAdded = Notification.Name("Subscription Added")
    static let celebrityBlocked = Notification.Name("Celebrity Blocked")
    static let celebrityUnblocked = Notification.Name("Celebrity Unblocked")
    static let logout = Notification.Name("Logoout")
    static let updateWallet = Notification.Name("Update Wallet")
    static let redirectApp = Notification.Name("Redirect App")
}

struct NotificationUserInfoKey {
    static let paymentSuccess = "Payment success status"
    static let redirectType = "Redirect Type"
}
