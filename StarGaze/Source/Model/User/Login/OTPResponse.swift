//
//  OTPResponse.swift
//  stargaze
//
//  Created by Girish Rathod on 10/02/22.
//

import Foundation
public struct OTPResponse : Codable{
    public var result : User
    
    enum CodingKeys: String, CodingKey{
        case result
    }
    
    public init(result: User){
        self.result = result
    }
}
