//
//  EventRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 22/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct EventRequest: Codable {
    let pageStart: Int!
    let limit:Int!
    let filters:String?
    
    enum CodingKeys: String, CodingKey {
        case pageStart = "start"
        case limit = "limit"
        case filters = "categories"
    }
}

extension EventRequest: Equatable {
    static func ==(lhs: EventRequest, rhs: EventRequest) -> Bool {
        return (lhs.limit == rhs.limit) && (lhs.pageStart == rhs.pageStart) && (lhs.filters == rhs.filters)
    }
}
