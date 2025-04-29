//
//  NotificationEndPoint.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 07/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum NotificationEndPoint {
    case getSettings
    case setSettings(NotificationSettings)
    case fcm(FirebaseMessagingRequest)
    case getList(NotificationListRequest)
    case markRead(NotificationReadRequest)
}

extension NotificationEndPoint: SGAPIEndPoint {
    var url: String {
        return URLEndPoints.notificationUrlString
    }
    
    var path: String {
        switch self {
        case .getSettings: return "user-preference/get-preferences"
        case .setSettings: return "user-preference/set-preferences"
        case .fcm: return "user/fcm"
        case .getList: return "notification/listing"
        case .markRead: return "notification/mark-read"
            
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSettings: return .get
        case .setSettings: return .post
        case .fcm: return .post
        case .getList: return .get
        case .markRead: return .post
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
        case .getSettings: return nil
        case .setSettings(let request): return request.dictionary
        case .fcm(let request): return request.dictionary
        case .getList(let request): return request.dictionary
        case .markRead(let request): return request.dictionary
        }
    }
    
    
}
