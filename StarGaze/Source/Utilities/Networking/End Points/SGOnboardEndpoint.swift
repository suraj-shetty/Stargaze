//
//  SGOnboardEndpoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGOnboardEndpoint: SGAPIEndPoint {
    case login(phoneNumber:PhoneNumber)
    case authenticate(info:VerifyOtp)
    case signin(request: SignInRequest)
    case verify(request: VerifyRequest)
    case socialSignin(request: SocialSignInRequest)
    case signup(request: SignUpRequest)
    case update(request: PhoneUpdateRequest)
    
    var url: String {
        return URLEndPoints.userBaseUrlString
    }
    
    var path: String {
        switch self {
        case .login: return "user/send-otp"
        case .authenticate: return "user/verify-otp"
        case .signin: return "user/send-otp"
        case .verify: return "user/verify-otp"
        case .socialSignin: return "user/social-login"
        case .signup: return "user/sign-up"
        case .update: return "user/update-mobile"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login: return .post
        case .authenticate: return .post
        case .signin, .verify, .socialSignin: return .post
        case .signup: return .post
        case .update: return .post
        }
    }
    
    
    var headers: [String : Any]? {
        return ["Content-Type": "application/json"]
    }
    
    var body: [String : Any]? {
        switch self {
        case .login(let phoneNumber):
            return phoneNumber.dictionary
            
        case .authenticate(let info):
            return info.dictionary
            
        case .signin(let request):
            return request.dictionary
            
        case .verify(let request):
            return request.dictionary
            
        case .socialSignin(let request):
            return request.dictionary
            
        case .signup(let request):
            return request.dictionary
            
        case .update(let request):
            return request.dictionary
        }
    }
}
