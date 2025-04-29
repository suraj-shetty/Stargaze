//
//  SGWalletEndPoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGWalletEndPoint {
    case getBalance
    case dailyRewards
    case transactions
}

extension SGWalletEndPoint: SGAPIEndPoint {
    var url: String {
        return URLEndPoints.subscriptionUrlString
    }
    
    var path: String {
        switch self {
        case .getBalance: return "coins/balance"
        case .dailyRewards:
            return "coins/my-daily-rewards"
        case .transactions:
            return "coins/wallet-list"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getBalance: return .get
        case .dailyRewards: return .get
        case .transactions: return .get
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
        case .getBalance: return nil
        case .dailyRewards: return nil
        case .transactions: return nil
        }
    }
    
    
}
