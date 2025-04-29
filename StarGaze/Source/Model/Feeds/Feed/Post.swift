//
//  Post.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import Foundation

public struct Post : Codable{
    var id : Int
    var description : String?
    var isCommentOn : Bool
    
    var createdAt : String
    var likeCount : Int
    var shareCount : Int
    var commentCount : Int
    var isExclusive : Bool
    
    var postCategory : [PostCategory]
    var postHashTag : [PostHashTag]?
    var media : [Media]
    var celeb : Celeb?
    var isLiked : Bool? 
    
    var aspectRatio: SGMediaAspectRatio?
    
    enum CodingKeys: String, CodingKey{
        case id
        case description
        case isCommentOn
        case createdAt
        case likeCount
        case shareCount
        case commentCount
        case isExclusive
        case postCategory
        case postHashTag
        case media
        case celeb
        case isLiked
        case aspectRatio = "mediaAspectRatio"
    }
    
    public init(id: Int, desc: String, is_comment_on: Bool, created_at : String, like_count : Int, share_count : Int, comment_count : Int, is_exclusive : Bool, post_category : [PostCategory], post_hash_tag : [PostHashTag], media : [Media], celeb : Celeb, is_liked : Bool?){
        self.id = id
        self.description = desc
        self.isCommentOn = is_comment_on
        self.createdAt = created_at
        self.likeCount = like_count
        self.shareCount = share_count
        self.commentCount = comment_count
        self.isExclusive = is_exclusive
        self.postCategory = post_category
        self.postHashTag = post_hash_tag
        self.media = media
        self.celeb = celeb
        self.isLiked = is_liked
    }
    
}
