//
//  URLEndPoints.swift
//  StarGaze
//
//  Created by Suraj Shetty on 14/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct URLEndPoints {
    
    static let urlPrefix = "https://"
    static let apiPostfix = "/api/v1/"
    
#if PROD
    static let baseURL_User = "api-user.stargaze.ai"
    static let baseURL_Social = "api-social.stargaze.ai"
    static let baseURL_Event = "api-event.stargaze.ai"
    static let baseURL_Subscription = "api-subscription.stargaze.ai"
    static let baseURL_Notifications = "api-notification.stargaze.ai"
#else    
    static let baseURL_User = "api-user-dev.stargaze.ai"
    static let baseURL_Social = "api-social-dev.stargaze.ai"
    static let baseURL_Event = "api-event-dev.stargaze.ai"
    static let baseURL_Subscription = "api-subscription-dev.stargaze.ai"
    static let baseURL_Notifications = "api-notification-dev.stargaze.ai"
#endif
    
    static let userBaseUrlString = urlPrefix + baseURL_User + apiPostfix
    static let socialBaseUrlString = urlPrefix + baseURL_Social + apiPostfix
    static let eventBaseUrlString = urlPrefix + baseURL_Event + apiPostfix
    static let subscriptionUrlString = urlPrefix + baseURL_Subscription + apiPostfix
    static let notificationUrlString = urlPrefix + baseURL_Notifications + apiPostfix
}
//https://a935-210-56-126-33.in.ngrok.io
