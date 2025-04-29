//
//  SGUserEndpoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGUserEndpoint: SGAPIEndPoint {
    case follow(String)
    case unfollow(String)
    case profile
    case updateProfile(EditProfileRequest)
    case report(ReportUserRequest)
    case block(String)
    case unblock(String)
    case deleteAccount
    case blockedList(BlockedListRequest)
    case earnings
    case earningTransactions(EarningTransactionsRequest)
    
    var url: String {
        return URLEndPoints.userBaseUrlString
    }
    
    var path: String {
        switch self {
        case .follow(_): return "follow/follow-user"
        case .unfollow(_): return "follow/un-follow-user"
        case .profile: return "user/getUser"
        case .updateProfile: return "user/profile"
        case .report: return "report/user-report"
        case .block: return "block/user-block"
        case .unblock: return "block/user-un-block"
        case .deleteAccount: return "user/delete"
        case .blockedList: return "block/my-list"
        case .earnings: return "user/earnings-dashboard"
        case .earningTransactions: return "user/my-earnings"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .profile, .blockedList: return .get
        case .deleteAccount: return .delete
        default: return .post
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
        case .follow(let userID): return ["followingId": userID]
        case .unfollow(let userID): return ["followingId": userID]
        case .profile: return nil
        case .updateProfile(let request): return request.dictionary
        case .report(let request): return request.dictionary
        case .block(let userID): return ["blockingId" : userID]
        case .unblock(let userID): return ["blockingId" : userID]
        case .deleteAccount: return nil
        case .blockedList(let request): return request.dictionary
        case .earnings: return nil
        case .earningTransactions(let request): return request.dictionary
        }
    }
    
    
    
}
