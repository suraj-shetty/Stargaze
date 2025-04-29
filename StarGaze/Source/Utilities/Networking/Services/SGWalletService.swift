//
//  SGWalletService.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SGWalletService {
    class func getWalletDetails() -> AnyPublisher<Wallet, SGAPIError> {
        let resultSubject: AnyPublisher<WalletResult, SGAPIError>
        = SGApiClient.shared
            .get(SGWalletEndPoint.getBalance)
            .map(\.value)
            .eraseToAnyPublisher()
        
        return resultSubject
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func getDailyRewards() -> AnyPublisher<[DailyReward], SGAPIError> {
        let result: AnyPublisher<DailyRewardResult, SGAPIError>
        = SGApiClient.shared
            .get(SGWalletEndPoint.dailyRewards)
            .map(\.value)
            .eraseToAnyPublisher()
        
        return result
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func getTransations() -> AnyPublisher<MyWalletResult, SGAPIError> {
        return SGApiClient.shared
            .get(SGWalletEndPoint.transactions)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
