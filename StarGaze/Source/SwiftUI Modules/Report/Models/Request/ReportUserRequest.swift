//
//  ReportUserRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 29/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct ReportUserRequest: Encodable {
    let userID: Int
    let reasons: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "reportingId"
        case reasons = "reason"
    }
}
