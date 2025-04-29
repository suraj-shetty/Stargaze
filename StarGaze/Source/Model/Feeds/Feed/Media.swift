//
//  Media.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import Foundation

public struct Media : Codable{
    let id : Int
    let mediaPath : String!
    let mediaType : SGMimeType!
    
    
    enum CodingKeys: String, CodingKey{
        case id
        case mediaPath
        case mediaType
    }
    
//    public init(id: Int, path: String, type: String){
//        self.id = id
//        self.mediaPath = path
//        self.mediaType = type
//    }
}


