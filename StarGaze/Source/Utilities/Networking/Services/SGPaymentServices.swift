//
//  SGPaymentServices.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SGPaymentServices {
    
    class func getList(for request: LeaderboardCategoryRequest) -> AnyPublisher<LeaderboardResult, SGAPIError> {
        return SGApiClient.shared
            .get(LeaderboardEndpoint.categories(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    class func initiateCoinsCreditTransaction(with request: CoinTransactionRequest) -> AnyPublisher<CoinTransactionResponse, SGAPIError> {
        let resultPublisher: AnyPublisher<CallResponse<CoinTransactionResponse>, SGAPIError>
        = SGApiClient.shared
            .run(PaymentEndpoint.initiateCoinTransaction(request))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return resultPublisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func creditCoins(with request: CoinCreditRequest) -> AnyPublisher<CoinCreditResponse, SGAPIError> {
        let resultPublisher: AnyPublisher<CallResponse<CoinCreditResponse>, SGAPIError>
        = SGApiClient.shared
            .run(PaymentEndpoint.creditCoins(request))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return resultPublisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func failedCoinCredit(with request: CoinCreditRequest) -> AnyPublisher<Bool, SGAPIError> {
        SGApiClient.shared
            .boolRun(PaymentEndpoint.creditCoins(request))
            .eraseToAnyPublisher()
    }
}
