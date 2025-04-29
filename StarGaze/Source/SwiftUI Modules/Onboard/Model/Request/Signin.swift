//
//  Signin.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 06/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SignInRequest: Encodable {
    enum SignInRequestType: String, Codable {
        case login = "login"
        case register = "register"
    }
    
    let input: String
    let countryCode: String?
    let type: SignInRequestType
    let hashString: String?
    
    enum CodingKeys: String, CodingKey {
        case input = "mobileoremail"
        case countryCode = "countryCode"
        case type
        case hashString
    }
}

struct VerifyRequest: Encodable {
    let input: String
    let countryCode: String?
    let pin: String
    
    enum CodingKeys: String, CodingKey {
        case input = "mobileoremail"
        case countryCode = "countryCode"
        case pin = "verificationOTP"
    }
}

struct SocialSignInRequest: Encodable {
    enum SocialSignType: String, Codable {
        case google = "google"
        case facebook = "fb"
        case apple = "apple"
    }
    
    let id: String
    let type: SocialSignType
    let name: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id = "socialId"
        case type = "socialType"
        case name = "userName"
        case email
    }
    
}

struct PhoneUpdateRequest: Encodable {
    let type: SocialSignInRequest.SocialSignType
    let id: String
    let number: String
    let dialCode: String
    
    enum CodingKeys: String, CodingKey {
        case id = "socialId"
        case type = "socialType"
        case number = "mobileNumber"
        case dialCode = "countryCode"
    }
}
