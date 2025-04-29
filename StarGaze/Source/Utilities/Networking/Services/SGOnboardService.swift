//
//  SGOnboardService.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SGOnboardService: HTTPClient {
    class func onboard(with info:PhoneNumber) -> AnyPublisher<Bool, SGAPIError> {
        return SGApiClient.shared
            .boolRun(SGOnboardEndpoint.login(phoneNumber: info))
            .eraseToAnyPublisher()
    }
    
    class func authenticate(with info: VerifyOtp) -> AnyPublisher<OTPResponse, SGAPIError> {
        return SGApiClient.shared
            .run(SGOnboardEndpoint.authenticate(info: info))
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    func login(with request: SignInRequest) async -> Result<LoginResult, SGAPIError> {
        return await sendRequest(endpoint: SGOnboardEndpoint.signin(request: request),
                                 responseModel: LoginResult.self)
    }
    
    func verifyPin(with request: VerifyRequest) async -> Result<UserDetailResult, SGAPIError> {
        return await sendRequest(endpoint: SGOnboardEndpoint.verify(request: request),
                                 responseModel: UserDetailResult.self)
    }
    
    func socialSignin(with request: SocialSignInRequest) async -> Result<UserDetailResult, SGAPIError> {
        return await sendRequest(endpoint: SGOnboardEndpoint.socialSignin(request: request),
                                 responseModel: UserDetailResult.self)
    }
    
    func verifySignupPin(with request: VerifyRequest) async -> Result<SignupOTPResult, SGAPIError> {
        return await sendRequest(endpoint: SGOnboardEndpoint.verify(request: request),
                                 responseModel: SignupOTPResult.self)
    }

    func signup(with request: SignUpRequest) async -> Result<UserDetailResult, SGAPIError> {
        return await sendRequest(endpoint: SGOnboardEndpoint.signup(request: request),
                                 responseModel: UserDetailResult.self)
    }
    
    func update(with request: PhoneUpdateRequest) async ->  Result<UserDetailResult, SGAPIError> {
        return await sendRequest(endpoint: SGOnboardEndpoint.update(request: request),
                                 responseModel: UserDetailResult.self)
    }
}
