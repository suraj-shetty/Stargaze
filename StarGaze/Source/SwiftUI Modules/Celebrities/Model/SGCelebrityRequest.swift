//
//  SGCelebrityRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 27/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
struct SGCelebrityRequest: Codable {
    let start:Int!
    let limit:Int!
    let search:String?
    let filters:String?
    
    enum CodingKeys: String, CodingKey {
        case start
        case limit
        case search
        case filters = "categories"
    }
}


struct SGCelebrityListResponse: Codable {
    let result:[SGCelebrity]
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}

//extension SGCelebrityRequest: Equatable {
//    static func ==(lhs: SGCelebrityRequest, rhs: SGCelebrityRequest) -> Bool {
//        return (lhs.category == rhs.category) && (lhs.pageToken == rhs.pageToken)
//    }
//}
