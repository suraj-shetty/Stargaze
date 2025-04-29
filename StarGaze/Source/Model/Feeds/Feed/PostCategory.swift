//
//  PostCategory.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import Foundation
public struct PostCategory : Codable{
    let id : Int
    let name : String

    enum CodingKeys: String, CodingKey{
        case id
        case name
    }
    
    public init(id: Int, name: String){
        self.id = id
        self.name = name
    }
}


