//
//  EventTimelineViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 24/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct EventTimelineViewModel: Identifiable {
    let id: Int
    let title: String
    let celebName: String
    let day: String
    let month: String
    let year: String
    let time: String
    
    let isFirst: Bool
    var hasPrevious: Bool
    
    func fullDateText() -> String {
        return "\(day) \(month) \(year)"
    }
}
