//
//  FirebaseMessagingRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 10/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum PlatformType: String, Codable {
    case iOS = "ios"
    case android = "android"
}

struct FirebaseMessagingRequest: Encodable {
    let token: String
    let platform: PlatformType        
}
