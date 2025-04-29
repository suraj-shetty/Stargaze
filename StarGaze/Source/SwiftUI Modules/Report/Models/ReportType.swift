//
//  ReportType.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 29/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum ReportType: String, CaseIterable {
    case abusive = "abusive_language"
    case inappropriate = "inappropriate_behaviour"
    case notListed = "reason_not_listed"
}

extension ReportType {
    var title: String {
        get {
            switch self {
            case .abusive:
                return "report.option.abusive.title"
            case .inappropriate:
                return "report.option.behaviour.title"
            case .notListed:
                return "report.option.not-listed.title"
            }
        }
    }
}
