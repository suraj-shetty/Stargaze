//
//  Comments.swift
//  stargaze
//
//  Created by Girish Rathod on 28/02/22.
//

import Foundation

public struct Comments : Codable{
    var id : Int
    var comment : String?
    var status : String?
    
    var likeCount : Int
    var createdAt : String
    var updatedAt : String?
    
    var postId : Int
    var userId : Int
    var parentPostCommentId : Int?
    
    var isLiked : String
    var user : CommentUser
    
    var replies:[SGReply]
    
    enum CodingKeys: String, CodingKey{
        case id
        case comment
        case status

        case likeCount
        case createdAt
        case updatedAt

        case postId
        case userId
        case parentPostCommentId

        case isLiked
        case user
        
        case replies = "parentPostComment"
    }
    
    public init(id: Int, comment: String, status: String, like_count: Int, created_at: String, updated_at: String, post_id: Int, user_id: Int, parentPostCommentId: Int?, is_liked: String, commentUser: CommentUser){
        self.id = id
        self.comment = comment
        self.status = status
        
        self.likeCount = like_count
        self.createdAt = created_at
        self.updatedAt = updated_at

        self.postId = post_id
        self.userId = user_id
        self.parentPostCommentId = parentPostCommentId

        self.isLiked = is_liked
        self.user = commentUser

        self.replies = []
    }
}


struct EventComments : Codable{
    var id : Int
    var comment : String?
    var status : String?
    
    var likeCount : Int?
    var createdAt : String
    
    var eventId : Int
    var userId : Int
    var parentEventCommentId : Int?
    
    var isLiked : String
    var user : CommentUser
    
    var replies:[SGEventReply]
    
    enum CodingKeys: String, CodingKey{
        case id
        case comment
        case status

        case likeCount
        case createdAt

        case eventId
        case userId
        case parentEventCommentId

        case isLiked
        case user
        
        case replies = "parentEventComment"
    }
}
