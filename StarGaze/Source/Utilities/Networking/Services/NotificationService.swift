//
//  NotificationService.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 07/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class NotificationService: HTTPClient {
    class func getSettings() -> AnyPublisher<NotificationSettings, SGAPIError> {
        let result: AnyPublisher<NotificationSettingResult, SGAPIError>
        = SGApiClient.shared
            .get(NotificationEndPoint.getSettings)
            .map(\.value)
            .eraseToAnyPublisher()
        
        return result
            .map(\.result)
            .eraseToAnyPublisher()                
    }
    
    class func save(settings: NotificationSettings) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(NotificationEndPoint.setSettings(settings))
            .eraseToAnyPublisher()
    }
    
    class func registerFirebaseToken(request: FirebaseMessagingRequest) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(NotificationEndPoint.fcm(request))
            .eraseToAnyPublisher()
    }
    
    //AppNotificationResult
    func getList(for request: NotificationListRequest) async -> Result<AppNotificationResult, SGAPIError> {
        return await sendRequest(endpoint: NotificationEndPoint.getList(request),
                                 responseModel: AppNotificationResult.self)
    }
    
    func markRead(for request: NotificationReadRequest) async -> Result<SuccessResponse, SGAPIError> {
        return await sendRequest(endpoint: NotificationEndPoint.markRead(request),
                                 responseModel: SuccessResponse.self)
    }
    
}
