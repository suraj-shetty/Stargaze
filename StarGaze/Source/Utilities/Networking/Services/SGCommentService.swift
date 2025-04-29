//
//  SGCommentService.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SGCommentService {
    class func comments(for feedID:Int, request:SGGetCommentsRequest) -> AnyPublisher<[Comments], SGAPIError> {
        let publisher:AnyPublisher<GetCommentResponse, SGAPIError> = SGApiClient.shared
            .get(SGFeedEndpoint.comments(feedID, request))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return publisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func postComment(request:SGCreateCommentRequest) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGFeedEndpoint.createComment(request))
            .eraseToAnyPublisher()
    }
    
    class func like(commentID:Int) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGFeedEndpoint.likeComment(commentID))
            .eraseToAnyPublisher()
    }
}
