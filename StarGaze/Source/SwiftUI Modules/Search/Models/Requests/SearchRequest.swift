//
//  SearchRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 27/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SearchRequest : Encodable {
    let search: String
    let startIndex: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case search = "search"
        case startIndex = "start"
        case pageSize = "limit"
    }
}
