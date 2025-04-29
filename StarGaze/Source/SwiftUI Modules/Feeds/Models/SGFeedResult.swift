//
//  SGFeedResult.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SGFeedResult: Codable {
    let result:Post
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}
