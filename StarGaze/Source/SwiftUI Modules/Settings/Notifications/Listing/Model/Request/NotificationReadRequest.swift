//
//  NotificationReadRequest.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 20/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct NotificationReadRequest: Encodable {
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "notificationId"
    }
}
