//
//  SGCelebrityEndpoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 27/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGCelebrityEndpoint {
    case celebrities(SGCelebrityRequest)
    case recommended(SGTopCelebRequest)
    case detail(Int)
    case videoCalls(request: CelebEventRequest)
    case shows(request: CelebEventRequest)
}

extension SGCelebrityEndpoint : SGAPIEndPoint {
    var url: String {
        switch self {
        case .celebrities: return URLEndPoints.userBaseUrlString
        case .recommended: return URLEndPoints.userBaseUrlString
            
        case .detail: return URLEndPoints.userBaseUrlString
            
        case .videoCalls: return URLEndPoints.eventBaseUrlString
        case .shows: return URLEndPoints.eventBaseUrlString            
        }
    }
    
    var path: String {
        switch self {
        case .celebrities: return "celebrity/get-all"
        case .recommended: return "celebrity/get-recommendations"
            
        case .detail(let id): return "celebrity/get-celeb/\(id)"
            
        case .videoCalls(let request): return "event/celeb-event/\(request.celebID)"
        case .shows(let request): return "show/celeb/\(request.celebID)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
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
        case .celebrities(let request): return request.dictionary
        case .recommended(let request): return request.dictionary
            
        case .detail: return nil
            
        case .videoCalls(let request): return request.dictionary
        case .shows(let request): return request.dictionary
        }
    }
    
    
}
