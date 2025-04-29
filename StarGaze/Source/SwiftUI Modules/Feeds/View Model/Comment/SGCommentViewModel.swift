//
//  SGCommentViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftDate
import Combine
import SwiftUI

class SGCommentUserViewModel: ObservableObject {
    let id:Int
    let name:String
    let userName:String
    let profilePath:String!
    
    init(id:Int, name:String, userName:String, profilePath:String?) {
        self.id = id
        self.name = name
        self.userName = userName
        self.profilePath = profilePath ?? ""
    }
    
    func displayName() -> String {
        return  name.isEmpty ? (userName.isEmpty ? "" : userName) : name
    }
}

class SGCommentViewModel: ObservableObject {
//    let id: String = UUID().uuidString
    
    let user:SGCommentUserViewModel
    let createdDate:Date?
    let comment:String
    let feedID:Int
    var parentCommentID:Int?
    let commentID:Int
    
    @Published var didLike:Bool = false
    @Published var showLike:Bool = false
    @Published var viewReplies:Bool = false
    @Published var canReply:Bool //To show reply button
    
    @Published var likeCount:Int

    @Published var replies:[SGCommentViewModel]
    
    @Published var hasError:Bool = false
    private(set) var error:SGAPIError? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(with comment:Comments) {
        self.commentID = comment.id
        self.feedID = comment.postId
        self.parentCommentID = comment.parentPostCommentId
        
        self.comment    = comment.comment ?? ""
        self.createdDate = comment.createdAt.toDate()?.date
        self.user   = SGCommentUserViewModel(id: comment.userId,
                                             name: comment.user.name ?? "",
                                             userName: comment.user.username ?? "",
                                             profilePath: comment.user.picture)
        
        switch comment.isLiked {
        case "1": self.didLike = true
        default: self.didLike = false
        }
                
        self.viewReplies = false
        self.canReply = (comment.parentPostCommentId == nil) //Only one level of reply allowed
        
        self.likeCount = comment.likeCount
        
        if (comment.likeCount > 0) {
            self.showLike = true
        }
        else {
            self.showLike = false
        }
        
        self.replies = comment.replies.map({
            let reply = SGCommentViewModel(reply: $0)
            reply.parentCommentID = comment.id
            return reply
        })
    }
    
    init(reply:SGReply) {
        self.commentID          = reply.id
        self.feedID             = reply.postID
        self.parentCommentID    = reply.commentID
        
        self.comment            = reply.comment
        self.createdDate        = reply.createdAt.toDate()?.date
        self.user   = SGCommentUserViewModel(id: reply.userID,
                                             name: reply.user.name ?? "",
                                             userName: reply.user.username ?? "",
                                             profilePath: reply.user.picture)
        
        switch reply.liked {
        case "1": self.didLike = true
        default: self.didLike = false
        }
        
        if (reply.likeCount > 0) {
            self.showLike = true
        }
        else {
            self.showLike = false
        }
        
        self.viewReplies = false
        self.likeCount = reply.likeCount
        
        self.canReply = false
        self.replies = []
    }
    

    init(with comment:EventComments) {
        self.commentID = comment.id
        self.feedID = comment.eventId
        self.parentCommentID = comment.parentEventCommentId
        
        self.comment    = comment.comment ?? ""
        self.createdDate = comment.createdAt.toDate()?.date
        self.user   = SGCommentUserViewModel(id: comment.userId,
                                             name: comment.user.name ?? "",
                                             userName: comment.user.username ?? "",
                                             profilePath: comment.user.picture)
        
        switch comment.isLiked {
        case "1": self.didLike = true
        default: self.didLike = false
        }
                
        self.viewReplies = false
        self.canReply = (comment.parentEventCommentId == nil) //Only one level of reply allowed
        
        self.likeCount = comment.likeCount ?? 0
        
        if (comment.likeCount ?? 0 > 0) {
            self.showLike = true
        }
        else {
            self.showLike = false
        }
        
        self.replies = comment.replies.map({
            let reply = SGCommentViewModel(reply: $0)
            reply.parentCommentID = comment.id
            return reply
        })
    }
    
    init(reply:SGEventReply) {
        self.commentID          = reply.id
        self.feedID             = reply.eventId
        self.parentCommentID    = reply.commentID
        
        self.comment            = reply.comment
        self.createdDate        = reply.createdAt.toDate()?.date
        self.user   = SGCommentUserViewModel(id: reply.userID,
                                             name: reply.user.name ?? "",
                                             userName: reply.user.username ?? "",
                                             profilePath: reply.user.picture)
        
        switch reply.liked {
        case "1": self.didLike = true
        default: self.didLike = false
        }
        
        if (reply.likeCount ?? 0 > 0) {
            self.showLike = true
        }
        else {
            self.showLike = false
        }
        
        self.viewReplies = false
        self.likeCount = reply.likeCount ?? 0
        
        self.canReply = false
        self.replies = []
    }
    
    deinit {
        cancellables.forEach({ $0.cancel() })
    }
    
    func toggleLike() {
        if didLike {
            likeCount -= 1
            didLike = false
            
            if likeCount > 0 {
                showLike = true
            }
            else {
                showLike = false
            }
            
        }
        else {
            likeCount += 1
            didLike = true
            showLike = true
        }
        
        
        SGCommentService.like(commentID: commentID)
            .sink { result in
                switch result {
                case .failure(let error):
                    self.error = error
                    self.hasError = true
                    
                case .finished: break
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)

    }
    
    func toggleReplies() {
        viewReplies.toggle()
    }
    
    
    func postReply() {
        
    }
    
    
}

extension SGCommentViewModel: Equatable {
    static func == (lhs: SGCommentViewModel, rhs: SGCommentViewModel) -> Bool {
        return lhs.commentID == rhs.commentID
    }
}
