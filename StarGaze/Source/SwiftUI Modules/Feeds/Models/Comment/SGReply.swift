//
//  SGReply.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct SGReply: Codable {
    let id: Int
    let postID: Int
    let commentID: Int
    let userID: Int
    let user: CommentUser
    let liked:String
    let likeCount:Int
    let comment: String
    let createdAt:String
    
    enum CodingKeys: String, CodingKey {
        case id
        case postID = "postId"
        case commentID = "parentPostCommentId"
        case userID = "userId"
        case user
        case liked = "isLiked"
        case likeCount
        case comment
        case createdAt
    }
}

struct SGEventReply: Codable {
    let id: Int
    let eventId: Int
    let commentID: Int
    let userID: Int
    let user: CommentUser
    let liked:String
    let likeCount:Int?
    let comment: String
    let createdAt:String
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "eventId"
        case commentID = "parentEventCommentId"
        case userID = "userId"
        case user
        case liked = "isLiked"
        case likeCount
        case comment
        case createdAt
    }
}
