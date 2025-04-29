//
//  SGCreateCommentRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SGCreateCommentRequest: Codable {
    let comment:String
    let feedID: Int
    let parentCommentID:Int?
    
    enum CodingKeys: String, CodingKey {
        case comment
        case feedID = "postId"
        case parentCommentID = "parentPostCommentId"
    }
}
