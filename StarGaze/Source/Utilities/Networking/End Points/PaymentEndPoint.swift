//
//  PaymentEndPoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum PaymentEndpoint {
    case initiateCoinTransaction(CoinTransactionRequest)
    case creditCoins(CoinCreditRequest)
}

extension PaymentEndpoint: SGAPIEndPoint {
    var url: String {
        return URLEndPoints.subscriptionUrlString
    }
    
    var path: String {
        switch self {
        case .initiateCoinTransaction: return "coins/create-coin-transaction"
        case .creditCoins: return "coins/buy"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .post
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
        case .initiateCoinTransaction(let request): return request.dictionary
        case .creditCoins(let request): return request.dictionary
        }
    }
    
    
}
