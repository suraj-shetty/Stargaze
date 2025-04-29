//
//  SGCelebrity.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGCelebrityStatus: String, Codable {
    case active = "active"
    case inActive = "inactive"
    case deleted = "deleted"
}

struct SGCelebrityInfo:Codable {
    let about:String
    
    enum CodingKeys: String, CodingKey {
        case about
    }
}

struct SGCelebrity: Codable, Identifiable, Equatable {
    let id:Int
    let name:String
    let status:SGCelebrityStatus
    let picture:String?
    let about:String?
    var isFollowed:Bool
    var followersCount:Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case picture
        case about = "about"
        case isFollowed = "isFollowing"
        case followersCount
    }
    
    static func == (lhs: SGCelebrity, rhs: SGCelebrity) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SGCelebrityResult: Codable {
    let result: SGCelebrity
}

extension Celeb {
    var profile: SGCelebrity {
        return SGCelebrity(id: self.id ?? 0,
                           name: self.name ?? "",
                           status: .active,
                           picture: self.picture,
                           about: nil,
                           isFollowed: false,
                           followersCount: 0)
    }
}
