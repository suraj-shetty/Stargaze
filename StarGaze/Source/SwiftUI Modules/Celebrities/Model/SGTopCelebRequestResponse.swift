//
//  SGTopCelebRequestResponse.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SGTopCelebRequest: Codable {
//    let nextPageID:String?
    let start:Int?
    let pageSize:Int?
    
    enum CodingKeys: String, CodingKey {
//        case nextPageID = "recommId"
        case start = "start"
        case pageSize = "limit"
    }
}

struct SGTrendingCelebResponse: Codable {
    var result:[SGCelebrity]
}

struct SGTrendingCelebResult:Codable {
    var output:[SGCelebrity]
    var nextPageID:String?
    
    enum CodingKeys: String, CodingKey {
        case output
        case nextPageID = "recommIds"
    }
}
