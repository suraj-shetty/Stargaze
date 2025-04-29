//
//  SGEventService.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SGEventService {
    class func createEvent(with request: EventCreateRequest) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGEventEndPoint.createEvent(request: request))
            .eraseToAnyPublisher()
    }
    
    class func getEvents(request: EventRequest) -> AnyPublisher<Events, SGAPIError> {
        return SGApiClient.shared
            .get(SGEventEndPoint.getEvents(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    class func likeEvent(isLiked: Bool, eventId: Int) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGEventEndPoint.likeEvent(isLiked: isLiked, eventId: eventId))
            .eraseToAnyPublisher()
    }
    
    class func share(eventID: Int) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGEventEndPoint.share(eventID))
            .eraseToAnyPublisher()
    }
    
    class func getEvent(eventId: Int) -> AnyPublisher<SingleEvent, SGAPIError> {
        return SGApiClient.shared
            .get(SGEventEndPoint.getEvent(eventId: eventId))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    class func joinEvent(coinType: String, eventId: Int) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGEventEndPoint.joinEvent(coinType: coinType, eventId: eventId))
            .eraseToAnyPublisher()
    }
    
    class func bidEvent(coins: Int, eventId: Int) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGEventEndPoint.bidEvent(coins: coins, eventId: eventId))
            .eraseToAnyPublisher()
    }
    
    class func getComments(eventId: Int) -> AnyPublisher<GetEventCommentResponse, SGAPIError> {
        return SGApiClient.shared
            .get(SGEventEndPoint.getComments(eventId: eventId))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    class func comment(eventId: Int, comment: String, parentCommentId: Int?) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGEventEndPoint.comment(eventId: eventId, comment: comment, parentcommentId: parentCommentId))
            .eraseToAnyPublisher()
    }
    
    class func eventHistory(request: EventHistoryRequest) -> AnyPublisher<[EventHistory], SGAPIError> {
        let resultPublisher: AnyPublisher<EventHistoryResult, SGAPIError> =
        SGApiClient.shared
            .get(SGEventEndPoint.eventHistory(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
                
        return resultPublisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func searchEvents(with request: SearchRequest) -> AnyPublisher<Events, SGAPIError> {
        return SGApiClient.shared
            .get(SGEventEndPoint.search(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
