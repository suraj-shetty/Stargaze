//
//  Register.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 07/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SignUpRequest: Encodable {
    let name: String
    let mobile: String
    let email: String
    let code: String
    let birthDate: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case mobile = "mobileNumber"
        case email
        case code = "countryCode"
        case birthDate = "dob"
    }
}
