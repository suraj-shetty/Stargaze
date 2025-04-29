//
//  MyEventRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 27/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct MyEventRequest: Encodable {
    let isCeleb: Bool
    let start: Int
    
    enum CodingKeys: String, CodingKey {
        case isCeleb = "celebHistory"
        case start = "start"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isCeleb ? 1 : 0, forKey: .isCeleb)
        try container.encode(start, forKey: .start)
    }
}
