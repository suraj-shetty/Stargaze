//
//  SGFeedEndpoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGFeedEndpoint {
    case getFeeds(type:SGFeedType, info:SGFeedRequest)
    case filters
    case create(SGCreatePostRequest)
    case like(Int)
    case getFeed(Int)
    case share(Int)
    case delete(Int)
    
    case comments(Int, SGGetCommentsRequest)
    case createComment(SGCreateCommentRequest)
    case likeComment(Int)
    case deleteComment(Int)
    
    case search(SearchRequest)
}

extension SGFeedEndpoint : SGAPIEndPoint {
    var url: String {
        switch self {
        case .filters: return URLEndPoints.eventBaseUrlString
        default: return URLEndPoints.socialBaseUrlString
        }
    }
    
    var path: String {
        switch self {
        case .getFeeds(let type, _):
            switch type {
            case .allFeedsList: return "feeds/list"
            case .myFollowings: return "feeds/my-followings"
            case .myFeeds: return "feeds/my-feeds"
            }
            
        case .filters:
            return "category/getAll"
            
        case .create(_):
            return "post/create"
            
        case .like(_):
            return "post/like"
            
        case .getFeed(let feedID):
            return "post/get-post/\(feedID)"
            
        case .share(let feedID):
            return "post/share/\(feedID)"
            
        case .delete(_):
            return "post/delete-post"
            
        case .comments(let feedID, _):
            return "post/get-comment/\(feedID)"
            
        case .createComment(_):
            return "post/comment"
            
        case .likeComment(_):
            return "post/like-comment"
            
        case .deleteComment(_):
            return "post/delete-comment"
            
        case .search(_):
            return "feeds/search"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .create(_), .like(_), .share(_), .likeComment(_), .createComment(_):
            return .post
            
        case .delete(_), .deleteComment(_):
            return .post
            
        default: return .get
        }
    }
    
    var headers: [String : Any]? {
        var requestHeader = ["Content-Type": "application/json"] as [String: Any]
        
        if let token = SGAppSession.shared.token, token.isEmpty == false {
            requestHeader["Authorization"] = "Bearer \(token)"
        }
        
        return requestHeader
    }
    
    var body: [String : Any]? {
        switch self {
        case .getFeeds(_, let info):        return info.dictionary
        case .create(let request):          return request.dictionary
        case .like(let feedID):             return ["postId":feedID]
        case .delete(let feedID):           return ["postId": feedID]
            
        case .comments(_, let request):     return request.dictionary
        case .createComment(let request):   return request.dictionary
        case .likeComment(let commentID):   return ["commentId": commentID]
        case .deleteComment(let commentID): return ["commentId": commentID]
            
        case .filters, .getFeed(_), .share(_):
            return [:]
            
        case .search(let request): return request.dictionary
        }
    }
}
