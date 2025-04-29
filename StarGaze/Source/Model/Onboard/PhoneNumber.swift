//
//  PhoneNumber.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import Foundation

public struct PhoneNumber : Codable{
    public var countryCode: String
    public var mobileNumber: String
    
    enum CodingKeys: String, CodingKey{
        case countryCode
        case mobileNumber
    }
    
    public init(code: String, number: String){
        self.countryCode = code
        self.mobileNumber = number
    }
}
