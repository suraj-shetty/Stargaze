//
//  PostLikeResponse.swift
//  stargaze
//
//  Created by Girish Rathod on 17/02/22.
//

import Foundation

public struct PostLikeResponse : Codable{
    public var result : String
    
    enum CodingKeys: String, CodingKey{
        case result
    }
    
    public init(result: String){
        self.result = result
    }
}
