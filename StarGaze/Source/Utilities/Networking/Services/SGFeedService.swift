//
//  SGFeedService.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine

class SGFeedService: NSObject {

    class func getFeeds(of type:SGFeedType, request:SGFeedRequest) -> AnyPublisher<Feeds, SGAPIError> {
        return SGApiClient.shared
            .get(SGFeedEndpoint.getFeeds(type: type, info: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    class func getFilters() -> AnyPublisher<[SGFilter], SGAPIError> {
        
        let resultPublisher:AnyPublisher<SGFilterResponse, SGAPIError> =
        SGApiClient.shared
            .get(SGFeedEndpoint.filters)
            .map(\.value)
            .eraseToAnyPublisher()
        
        return resultPublisher
            .map(\.result)            
            .eraseToAnyPublisher()
    }
    
    
    class func createPost(request:SGCreatePostRequest) -> AnyPublisher<Bool,SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGFeedEndpoint.create(request))
            .eraseToAnyPublisher()
    }
    
    class func likeFeed(feed:Post) -> AnyPublisher<Bool,SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGFeedEndpoint.like(feed.id))
            .eraseToAnyPublisher()
    }
    
    class func shareFeed(feed:Post) -> AnyPublisher<Bool,SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGFeedEndpoint.share(feed.id))
            .eraseToAnyPublisher()
    }
    
    class func getFeed(id:Int) -> AnyPublisher<Post, SGAPIError> {
        let publisher: AnyPublisher<SGFeedResult, SGAPIError> = SGApiClient.shared
            .run(SGFeedEndpoint.getFeed(id))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return publisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func delete(_ feed:Post) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGFeedEndpoint.delete(feed.id))
            .eraseToAnyPublisher()
    }
    
    class func search(for request: SearchRequest) -> AnyPublisher<Feeds, SGAPIError> {
        return SGApiClient.shared
            .get(SGFeedEndpoint.search(request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
