//
//  SGFilter.swift
//  StarGaze
//
//  Created by Suraj Shetty on 01/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGFilterStatus: String, Codable {
    case active = "active"
    case inActive = "inactive"
    case deleted = "deleted"
}

struct SGFilter: Codable {
    let id:Int
    let name:String!
    let status:SGFilterStatus!
    let parentID:Int?
    var subFilters:[SGFilter]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case parentID = "parentCategoryId"
    }
}

extension SGFilter: Equatable {
    static func == (lhs: SGFilter, rhs: SGFilter) -> Bool {
        return lhs.id == rhs.id
    }
}
