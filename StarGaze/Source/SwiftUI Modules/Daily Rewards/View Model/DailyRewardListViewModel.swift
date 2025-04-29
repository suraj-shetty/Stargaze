//
//  DailyRewardListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 09/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

class DailyRewardListViewModel: ObservableObject, Identifiable {
    let rewards: [DailyReward]
    let id = UUID()
    
    init(rewards: [DailyReward]) {
        self.rewards = rewards
    }
}
