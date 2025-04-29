//
//  AppNotification.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 20/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct AppNotification: Decodable {
    let id: Int
    let type: APNSType?
    let typeID: Int?
    let title: String
    let message: String
    let createdDate: Date
    var didRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case typeID = "type_id"
        case title
        case message
        case createdDate = "createdAt"
        case didRead = "isRead"
    }
}

struct AppNotificationResult: Decodable {
    let result: [AppNotification]
}
