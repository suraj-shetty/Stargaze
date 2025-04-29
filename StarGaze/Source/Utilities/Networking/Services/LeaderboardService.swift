//
//  LeaderboardService.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class LeaderboardService {
    class func getList(for request: LeaderboardCategoryRequest) -> AnyPublisher<LeaderboardResult, SGAPIError> {
        return SGApiClient.shared
            .get(LeaderboardEndpoint.categories(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    class func getDetails(for request: LeaderboardDetailRequest) -> AnyPublisher<LeaderboardDetail, SGAPIError> {
        return SGApiClient.shared
            .get(LeaderboardEndpoint.details(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
