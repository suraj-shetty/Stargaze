//
//  LoginResponse.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 06/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct LoginResponse: Decodable {
    let isAccountPresent: Bool
    
    enum CodingKeys: String, CodingKey {
        case isAccountPresent = "isUserExist"
    }
}

struct LoginResult: Decodable {
    let result: LoginResponse
}
