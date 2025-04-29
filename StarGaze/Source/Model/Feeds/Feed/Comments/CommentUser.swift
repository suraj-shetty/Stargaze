//
//  CommentUser.swift
//  stargaze
//
//  Created by Girish Rathod on 28/02/22.
//

import Foundation

public struct CommentUser : Codable{
    public var name : String?
    public var picture : String?
    public var username : String?

    
    enum CodingKeys: String, CodingKey{
        case name
        case picture
        case username
    }
    
    public init(name: String?, pictureLink: String?, userName: String?){
        self.name = name
        self.picture = pictureLink
        self.username = userName
    }
    
}
