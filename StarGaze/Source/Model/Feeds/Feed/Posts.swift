//
//  Posts.swift
//  stargaze
//
//  Created by Girish Rathod on 11/02/22.
//

import Foundation

public struct Posts : Codable{
    public var posts : [Post]
    public var recommId : String?

    enum CodingKeys: String, CodingKey{
        case posts
        case recommId
    }
    
    public init(posts: [Post], recomm_id: String?){
        self.posts = posts
        self.recommId = recomm_id ?? ""
    }
}
