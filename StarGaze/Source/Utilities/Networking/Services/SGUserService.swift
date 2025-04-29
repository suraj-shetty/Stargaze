//
//  SGUserService.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SGUserService: HTTPClient {
    class func follow(userID:String) -> AnyPublisher<FollowResult, SGAPIError> {
        let publisher: AnyPublisher<FollowResponse, SGAPIError>
        = SGApiClient.shared
            .run(SGUserEndpoint.follow(userID))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return publisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func unFollow(userID:String) -> AnyPublisher<FollowResult, SGAPIError> {
        let publisher: AnyPublisher<FollowResponse, SGAPIError>
        = SGApiClient.shared
            .run(SGUserEndpoint.unfollow(userID))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return publisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func getProfile(with token: String? = nil) -> AnyPublisher<UserDetail, SGAPIError> {
        if let token = token, !token.isEmpty {
            SGAppSession.shared.token = token
            SGUserDefaultStorage.saveToken(token: token)
        }
        
        let resultPublisher: AnyPublisher<UserDetailResult, SGAPIError>
        = SGApiClient.shared
            .get(SGUserEndpoint.profile)
            .map(\.value)
            .eraseToAnyPublisher()
        
        return resultPublisher
            .map(\.result)
            .eraseToAnyPublisher()
    }
    
    class func updateProfile(with request: EditProfileRequest) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGUserEndpoint.updateProfile(request))
            .eraseToAnyPublisher()
    }
    
    class func report(with request: ReportUserRequest) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGUserEndpoint.report(request))
            .eraseToAnyPublisher()
    }
    
    class func block(userID: String) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGUserEndpoint.block(userID))
            .eraseToAnyPublisher()
    }

    class func unblock(userID: String) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGUserEndpoint.unblock(userID))
            .eraseToAnyPublisher()
    }
    
//    class func getNotifPreference() -
    
    static let shared = SGUserService()
    
    func deleteAccount() async -> Result<SuccessResponse, SGAPIError> {
        return await sendRequest(endpoint: SGUserEndpoint.deleteAccount,
                                 responseModel: SuccessResponse.self)
    }
    
    func getBlockedList(request: BlockedListRequest) -> AnyPublisher<[BlockedUser], SGAPIError> {
        let result: AnyPublisher<BlockedUserResult, SGAPIError> =
        SGApiClient.shared
            .get(SGUserEndpoint.blockedList(request))
            .map(\.value)
            .eraseToAnyPublisher()
        
        return result.map(\.result)
            .eraseToAnyPublisher()
    }
    
    func earnings() async -> Result<EarningsResult, SGAPIError> {
        return await sendRequest(endpoint: SGUserEndpoint.earnings,
                                 responseModel: EarningsResult.self)
    }
    
    func getMyEarnings(request: EarningTransactionsRequest) async -> Result<EarningListResult, SGAPIError> {
        return await sendRequest(endpoint: SGUserEndpoint.earningTransactions(request),
                                 responseModel: EarningListResult.self)
    }
}
