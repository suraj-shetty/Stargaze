//
//  ErrorResponse.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 19/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation


struct ErrorResponse: Codable {
    let error:ErrorDetail
}

struct ErrorDetail: Codable {
    let errors:[String]
    let info: [ErrorInfo]?
    let code: Int
    
    enum CodingKeys: String, CodingKey {
        case errors
        case info = "error_params"
        case code
    }
}

struct ErrorInfo: Codable {
    let msg: String
    
    enum CodingKeys: String, CodingKey {
        case msg
    }
}
