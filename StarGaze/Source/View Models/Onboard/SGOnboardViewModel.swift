//
//  SGOnboardViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine

class SGOnboardViewModel: NSObject {

    var phoneNumber:String!
    var countryCode:String!
    
    private var cancellables = Set<AnyCancellable>()
    
    func onboard(completion:@escaping (Bool, SGAPIError?)-> Void) {
        let info = PhoneNumber(code: countryCode, number: phoneNumber)
        SGOnboardService.onboard(with: info)
            .sink { result in
                switch result {
                case .failure(let error): completion(false, error)
                case .finished: break
                }
            } receiveValue: { didOnboard in
                completion(didOnboard, nil)
            }
            .store(in: &cancellables)

    }
    
    func authenticate(with otp:String, completion:@escaping (UserDetail?, SGAPIError?)-> Void) {
        let info = VerifyOtp(otpCode: otp,
                             number: .init(code: countryCode,
                                           number: phoneNumber))
        
        let authRequest = SGOnboardService.authenticate(with: info)
        let authResponse:AnyPublisher<UserDetail, SGAPIError> = authRequest.compactMap({ $0.result})
            .flatMap({ user in                
                return SGUserService.getProfile(with: user.token)
            })
            .eraseToAnyPublisher()        
        
        authResponse
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error): completion(nil, error)
                case .finished: break
                }
            }, receiveValue: { detail in
                completion(detail, nil)
            })
            .store(in: &cancellables)
    }
}
