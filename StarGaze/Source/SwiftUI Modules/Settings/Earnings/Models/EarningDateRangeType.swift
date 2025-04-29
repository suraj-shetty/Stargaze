//
//  EarningDateRangeType.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import Foundation


enum EarningDateRangeType: Int {
    case month = 0
    case quarter = 1
    case halfYear = 2
    case year = 3
}

extension EarningDateRangeType {
    var title: String {
        switch self {
        case .month:
            return "This month"
        case .quarter:
            return "Last 3 months"
        case .halfYear:
            return "Last 6 months"
        case .year:
            return "Last 12 months"
        }
    }
    
    static var allOptions: [EarningDateRangeType] {
        return [.month, .quarter, .halfYear, .year]
    }
}
