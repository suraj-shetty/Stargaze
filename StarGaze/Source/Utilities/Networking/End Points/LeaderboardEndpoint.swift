//
//  LeaderboardEndpoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum LeaderboardEndpoint {
    case categories(request: LeaderboardCategoryRequest)
    case details(request: LeaderboardDetailRequest)
}

extension LeaderboardEndpoint: SGAPIEndPoint {
    var url: String {
        return URLEndPoints.subscriptionUrlString
    }
    
    var path: String {
        switch self {
        case .categories: return "leaderboard/list"
        case .details: return "leaderboard/details"
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
        case .categories(let request): return request.dictionary
        case .details(let request): return request.dictionary
        }
    }
    
    
}
