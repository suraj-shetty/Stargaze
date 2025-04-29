//
//  SubscriptionEndPoint.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SubscriptionEndpoint {
    case getPlans(SubscriptionPlanRequest?)
    case addCelebSubscription(CelebSubscriptionRequest)
    case addAppSubscription(AppSubScriptionRequest)
    case subscriptions
}

extension SubscriptionEndpoint: SGAPIEndPoint {
    var url: String {
        return URLEndPoints.subscriptionUrlString
    }
    
    var path: String {
        switch self {
        case .getPlans:
            return "subscription/get-subscriptions-plans"
            
        case .addAppSubscription:
            return "subscription/entire"
            
        case .addCelebSubscription:
            return "subscription/initiate-subscription"
            
        case .subscriptions:
            return "subscription/list"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getPlans, .subscriptions:
            return .get
            
        case .addCelebSubscription, .addAppSubscription:
            return .post
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
        case .getPlans(let request):
            return request?.dictionary
            
        case .addAppSubscription(let request):
            return request.dictionary
            
        case .addCelebSubscription(let request):
            return request.dictionary
            
        case .subscriptions:
            return nil
        }
    }
    
    
}
