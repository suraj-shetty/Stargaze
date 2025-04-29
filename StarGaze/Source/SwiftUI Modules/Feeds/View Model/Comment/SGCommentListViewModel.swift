//
//  SGCommentListViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine

enum CommentsType {
    case feed
    case event
}

class SGCommentListViewModel: ObservableObject, Identifiable {
    private let commentsType: CommentsType
    
    private(set) var viewModel:SGFeedViewModel?
    private(set) var newComment:SGCommentViewModel? {
        willSet {
            if newValue != nil {
                newCommentChange.send(newValue!)
            }
        }
    }
    
    @Published var didEnd:Bool = false
    @Published var comments = [SGCommentViewModel]()
    
    @Published var didPost:Bool = false
    @Published var hasError:Bool = false
    
    @Published var commentPosting:Bool = false
    @Published var allowCommenting: Bool = false
    
    private(set) var error:SGAPIError?
        
    private var currentRequest: SGGetCommentsRequest?
    private var cancellables = Set<AnyCancellable>()
    private var subscriptionCancellable: AnyCancellable?
    
    let newCommentChange = PassthroughSubject<SGCommentViewModel, Never>()
    let id: Int
    
    init(viewModel:SGFeedViewModel) {
        self.commentsType = .feed
        self.viewModel = viewModel
        self.eventId = nil
        self.id = viewModel.id
                
        let canComment = SGAppSession.shared.canComment(on: viewModel.celebID ?? 0)
        self.allowCommenting = canComment
        
        self.subscriptionCancellable = SGAppSession.shared.subscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] _ in
                let canComment = SGAppSession.shared.canComment(on: viewModel.celebID ?? 0)
                self?.allowCommenting = canComment
            })
            
    }
    
    // MARK: - Events vars
    let eventId: Int?
    init(eventId: Int, celebID: Int?) {
        self.commentsType = .event
        self.eventId = eventId
        self.viewModel = nil
        self.id = eventId
        
        let canComment = SGAppSession.shared.canComment(on: celebID ?? 0)
        self.allowCommenting = canComment
        
        self.subscriptionCancellable = SGAppSession.shared.subscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] _ in
                let canComment = SGAppSession.shared.canComment(on: celebID ?? 0)
                self?.allowCommenting = canComment
            })
    }
    //
    
    func getComments(refresh:Bool) {
        if commentsType == .event {
            getEventComments(refresh: refresh)
        } else {
            getFeedComments(refresh: refresh)
        }
    }
    
    func postComment(comment:String, parentComment:SGCommentViewModel?) {
        if commentsType == .event {
            postEventComment(comment: comment, parentComment: parentComment)
        } else {
            postFeedComment(comment: comment, parentComment: parentComment)
        }
    }
    
    private func updateList(with comments:[SGCommentViewModel], parentComment:SGCommentViewModel?) {
        if let comment = parentComment {
            if comment.replies.isEmpty {
                comment.replies = comments
            }
            else {
                comments.reversed().forEach { updatedComment in
                    if let index = comment.replies.firstIndex(of: updatedComment) {
                        comment.replies[index] = updatedComment
                    }
                    else {
                        comment.replies.insert(updatedComment, at: 0) //New comments are to be at top
                    }
                }
            }
            
            if let index = self.comments.firstIndex(of: comment) {
                self.comments[index] = comment
            }
        }
        
        else {
            comments.reversed().forEach {[unowned self] updatedComment in
                if let index = self.comments.firstIndex(of: updatedComment) {
                    self.comments[index] = updatedComment
                }
                else {
                    self.comments.insert(updatedComment, at: 0) //New comments are to be at top
                }
            }
        }
    }
}

// MARK: -  Feed comments functions
extension SGCommentListViewModel {
    func getFeedComments(refresh:Bool) {
        guard let feedViewModel = viewModel else { return }
        if refresh == false {
            if didEnd == true || currentRequest != nil {
                return
            }
        }
        
        currentRequest = SGGetCommentsRequest(start: comments.count,
                                              limit: 30,
                                              parentID: nil)
        SGCommentService.comments(for: feedViewModel.id,
                                  request: currentRequest!)
        .sink { result in
            switch result {
            case .failure(let error):
                self.error = error
                self.hasError = true
                
            case .finished: break
            }
        } receiveValue: { comments in
            if comments.count < 30 {
                self.didEnd = true
            }
            
            if refresh {
                self.comments.removeAll()
            }
            
            let viewModels = comments.map({ SGCommentViewModel(with: $0) })
            self.comments.append(contentsOf: viewModels)
        }
        .store(in: &cancellables)
    }
    
    func postFeedComment(comment:String, parentComment:SGCommentViewModel?) {
        guard let feedViewModel = viewModel else { return }

        let parentCommentID = parentComment?.commentID
        let request = SGCreateCommentRequest(comment: comment,
                                             feedID: feedViewModel.id,
                                             parentCommentID: parentCommentID)
                        
        commentPosting = true
        SGCommentService.postComment(request: request)
            .flatMap { _ in
                return SGCommentService.comments(for: feedViewModel.id,
                                                 request: SGGetCommentsRequest(start: 0,
                                                                               limit: 5,
                                                                               parentID: parentCommentID)) //Receive the lastest comments
            }
            .sink { result in
                switch result {
                case .failure(let error):
                    self.error = error
                    self.hasError = true
                    self.commentPosting = false
                    
                case .finished: break
                }
            } receiveValue: {[weak self] comments in
                let commentsList = comments.map({ SGCommentViewModel(with: $0) })
                
                self?.updateList(with: commentsList,
                                 parentComment: parentComment)
                
                self?.commentPosting = false
                self?.didPost = true
                self?.newComment = commentsList.first
                self?.viewModel?.commentCount += 1
            }
            .store(in: &cancellables)
    }
}

// MARK: -  Events comments functions
extension SGCommentListViewModel {
    func getEventComments(refresh: Bool) {
        guard let eventId = eventId else { return }
        SGEventService.getComments(eventId: eventId)
            .sink { result in
                switch result {
                case .failure(let error):
                    self.error = error
                    self.hasError = true
                    
                case .finished: break
                }
            } receiveValue: { commentResponse in
                if commentResponse.result.count < 30 {
                    self.didEnd = true
                }
                
                if refresh {
                    self.comments.removeAll()
                }
                
                let viewModels = commentResponse.result.map({ SGCommentViewModel(with: $0) })
                self.comments.append(contentsOf: viewModels)
            }
            .store(in: &cancellables)
    }
    
    func postEventComment(comment:String, parentComment:SGCommentViewModel?) {
        guard let eventId = eventId else { return }
        let parentCommentID = parentComment?.commentID
        commentPosting = true
        
        SGEventService.comment(eventId: eventId, comment: comment, parentCommentId: parentCommentID)
            .flatMap { _ in
                return SGEventService.getComments(eventId: eventId)
            }
            .sink { result in
                switch result {
                case .failure(let error):
                    self.error = error
                    self.hasError = true
                    self.commentPosting = false
                    
                case .finished: break
                }
            } receiveValue: {[weak self] commentResponse in
                let commentsList = commentResponse.result.map({ SGCommentViewModel(with: $0) })
                
                self?.updateList(with: commentsList,
                                 parentComment: parentComment)
                
                self?.commentPosting = false
                self?.didPost = true
                self?.newComment = commentsList.first
            }
            .store(in: &cancellables)
    }
}

extension SGCommentListViewModel: Equatable {
    static func == (lhs: SGCommentListViewModel, rhs: SGCommentListViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
