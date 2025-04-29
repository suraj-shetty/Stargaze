//
//  CelebEventRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 04/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct CelebEventRequest: Encodable {
    let celebID: Int
    let startIndex: Int
    let count: Int
    
    private enum CodingKeys: String, CodingKey {
        case startIndex = "start"
        case limit
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startIndex, forKey: .startIndex)
        try container.encode(count, forKey: .limit)
    }
}
