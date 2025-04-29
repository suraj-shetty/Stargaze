//
//  VerifyOtp.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import Foundation

public struct VerifyOtp : Codable{
    public var mobileNumber: String
    public var countryCode: String
    public var mobileVerificationOTP: String
    
    enum CodingKeys: String, CodingKey{
        case mobileNumber
        case countryCode
        case mobileVerificationOTP
    }
    
    public init(otpCode: String, number: PhoneNumber){
        self.mobileNumber = number.mobileNumber
        self.countryCode = number.countryCode
        self.mobileVerificationOTP = otpCode
    }
}
