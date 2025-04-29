//
//  SubscriptionServices.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine


class SubscriptionServices: HTTPClient {
    static let shared = SubscriptionServices()
    
    class func getPlans(request: SubscriptionPlanRequest? = nil) -> AnyPublisher<[SubscriptionPlan], SGAPIError> {
        let result: AnyPublisher<SubscriptionPlanResult, SGAPIError>
        = SGApiClient.shared
            .get(SubscriptionEndpoint.getPlans(request))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return result
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    
    func addCelebSubscription(with request: CelebSubscriptionRequest) async -> Result<SuccessResponse, SGAPIError> {
        return await sendRequest(endpoint: SubscriptionEndpoint.addCelebSubscription(request),
                                 responseModel: SuccessResponse.self)
    }
    
    func addAppSubscription(with request: AppSubScriptionRequest) async -> Result<SuccessResponse, SGAPIError> {
        return await sendRequest(endpoint: SubscriptionEndpoint.addAppSubscription(request),
                                 responseModel: SuccessResponse.self)
    }
    
    func getList() async -> Result<SubscriptionItemList, SGAPIError> {
        return await sendRequest(endpoint: SubscriptionEndpoint.subscriptions,
                                 responseModel: SubscriptionItemList.self)
    }
}
