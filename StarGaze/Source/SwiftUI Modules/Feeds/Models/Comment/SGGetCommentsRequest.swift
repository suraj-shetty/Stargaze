//
//  SGGetCommentsRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SGGetCommentsRequest: Codable {
    let start:Int
    let limit: Int
    let parentID:Int?
    
    enum CodingKeys: String, CodingKey {
        case start
        case limit
        case parentID = "parentCommentId"
    }
}
//extension SGGetCommentsRequest : Equatable {
//    static func == (lhs:SGGetCommentsRequest, rhs:SGGetCommentsRequest) -> Bool {
//        return (lhs.feedID == rhs.feedID)
//    }
//}
