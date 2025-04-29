//
//  SGFeedRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SGFeedRequest: Codable {
        
    let pageToken:String?
    let pageStart: Int!
    let limit:Int!
    let filters:String?
//    let category: SGFeedCategory!
    let userID:String?
    
    enum CodingKeys: String, CodingKey {
        case pageToken = "recommId"
        case pageStart = "start"
        case limit = "limit"
        case filters = "categories"
//        case category = "isExclusive"
        case userID = "userId"
    }
}

extension SGFeedRequest: Equatable {
    static func ==(lhs: SGFeedRequest, rhs: SGFeedRequest) -> Bool {
        return (lhs.limit == rhs.limit) && (lhs.pageStart == rhs.pageStart)
    }
}
