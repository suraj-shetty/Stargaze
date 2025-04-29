//
//  SGEventEndPoint.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGEventEndPoint {
    case createEvent(request: EventCreateRequest)
    case getEvents(request: EventRequest)
    case likeEvent(isLiked: Bool, eventId: Int)
    case share(Int)
    case getEvent(eventId: Int)
    case joinEvent(coinType: String, eventId: Int)
    case bidEvent(coins: Int, eventId: Int)
    case getComments(eventId: Int)
    case comment(eventId: Int, comment: String, parentcommentId: Int?)
    
    case eventHistory(request: EventHistoryRequest)
    case myEventHistory(request: MyEventRequest)
    
    case search(request: SearchRequest)
}

extension SGEventEndPoint: SGAPIEndPoint {
    var url: String {
        return URLEndPoints.eventBaseUrlString
    }
    
    var path: String {
        switch self {
        case .createEvent:
            return "event/create"
        case .getEvents:
            return "event/listing"
        case .likeEvent:
            return "event/like"
        case .share(let eventID):
            return "event/\(eventID)/share"
        case .getEvent(let eventId):
            return "event/\(eventId)"
        case .joinEvent:
            return "event/join"
        case .bidEvent:
            return "event/bid"
        case .getComments(let eventId):
            return "event/\(eventId)/comment"
        case .comment:
            return "event/comment"
        case .eventHistory, .myEventHistory:
            return "event/my-list"
            
        case .search:
            return "event/listing"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .createEvent, .likeEvent, .joinEvent, .bidEvent, .comment, .share:
            return .post
        case .getEvents, .getEvent, .getComments, .eventHistory, .myEventHistory:
            return .get
        case .search(_):
            return .get
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
        case .createEvent(let request):
            return request.dictionary
            
        case .getEvents(let request):
            return request.dictionary
            
        case .likeEvent(let isLiked, let eventId):
            return ["isLiked": isLiked, "eventId": "\(eventId)"]
        case .joinEvent(_, let eventId):
            return ["eventId": "\(eventId)", "description": "Celebrity Video Call"]
//            return ["coinType": coinType, "eventId": "\(eventId)", "description": "Celebrity Video Call"]
        case .bidEvent(let coins, let eventId):
            return ["coins": coins, "eventId": "\(eventId)", "description": "Redeem coins on Celebrity video call"]
        case .comment(let eventId, let comment, let parentcommentId):
            var params: [String: Any] = ["eventId": eventId, "comment": comment]
            if parentcommentId != nil {
                params["parentCommentId"] = parentcommentId!
            }
            return params
            
        case .eventHistory(let request):
            return request.dictionary
            
        case .myEventHistory(let request):
            return request.dictionary
            
        case .search(let request):
            return request.dictionary
            
        default:
            return nil
        }
    }
}
