//
//  SubscriptionViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 29/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SubscriptionViewModel: Identifiable {
    let id: Int
    let title: String
    let cost: Int
    let desc: [String]
    let type: SubscriptionTypes
}

extension SubscriptionViewModel {
    static func fullApp() -> SubscriptionViewModel {
        return SubscriptionViewModel(id: 0,
                                     title: "Unlock Complete App",
                                     cost: 99,
                                     desc: [
                                        "Exclusive content",
                                        "Priority to win the video calls",
                                        "Ability to comment",
                                        "Message the stars privately"
                                       ],
                                     type: .appUnlock)
    }
    
    static func comment() -> SubscriptionViewModel {
        return SubscriptionViewModel(id: 0,
                                     title: "Unlock Entire App Comments",
                                     cost: 15,
                                     desc: [
                                        "Add free",
                                        "Unlimited comments"
                                       ],
                                     type: .comments)
    }
}
