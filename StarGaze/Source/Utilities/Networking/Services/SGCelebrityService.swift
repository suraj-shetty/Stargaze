//
//  SGCelebrityService.swift
//  StarGaze
//
//  Created by Suraj Shetty on 27/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SGCelebrityService {
    class func fetchCelebrities(for request:SGCelebrityRequest) -> AnyPublisher<[SGCelebrity], SGAPIError> {
        let listPublisher: AnyPublisher<SGCelebrityListResponse, SGAPIError>
        = SGApiClient.shared
            .get(SGCelebrityEndpoint.celebrities(request))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return listPublisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func fetchRecommendation(for request:SGTopCelebRequest) -> AnyPublisher<[SGCelebrity], SGAPIError> {
        let listPublisher: AnyPublisher<SGTrendingCelebResponse, SGAPIError>
        = SGApiClient.shared
            .get(SGCelebrityEndpoint.recommended(request))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return listPublisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func fetchDetail(for id: Int) -> AnyPublisher<SGCelebrity, SGAPIError> {
        let resultPublisher: AnyPublisher<SGCelebrityResult, SGAPIError>
        = SGApiClient.shared
            .get(SGCelebrityEndpoint.detail(id))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return resultPublisher
            .map(\.result)
            .eraseToAnyPublisher()        
    }
    
    class func fetchVideoCalls(for request:CelebEventRequest) -> AnyPublisher<Events, SGAPIError> {
        return SGApiClient.shared
            .get(SGCelebrityEndpoint.videoCalls(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    class func fetchShows(for request:CelebEventRequest) -> AnyPublisher<Events, SGAPIError> {
        return SGApiClient.shared
            .get(SGCelebrityEndpoint.shows(request: request))
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
