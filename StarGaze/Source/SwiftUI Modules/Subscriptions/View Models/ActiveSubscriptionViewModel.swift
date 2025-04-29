//
//  ActiveSubscriptionViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 05/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct ActiveSubscriptionViewModel: Identifiable {
    var id: Int
    var celebName: String
    var cost: Int
    var nextDate: String?
    var packageType: SubscriptionPackageType
}
