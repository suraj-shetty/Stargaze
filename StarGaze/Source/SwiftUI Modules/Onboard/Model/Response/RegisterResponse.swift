//
//  RegisterResponse.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 07/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SignupOTPResponse: Decodable {
    let mobileNumber: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case mobileNumber
        case message
    }
}

struct SignupOTPResult: Decodable {
    let result: SignupOTPResponse
}
