//
//  EventSocketModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct EventProbabilityUpdate: Codable {
    let eventID: Int
    let userID: Int
    let probability: Double
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case userID = "userId"
        case probability = "probability"
    }
}

struct EventUpdate: Codable {
    let eventID: Int
    let type: EventUpdateType
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case type = "realTimeType"
    }
}

struct EventCounterUpdate: Codable {
    let eventID: Int
    let count: Int
    let type: EventCountType
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case count = "count"
        case type = "realTimeType"
    }
}

enum EventCountType: String, Codable {
    case newJoin = "new_join"
    case comment = "comment"
    case like   = "like"
    case share = "share"
}

enum EventUpdateType: String, Codable {
    case eventUpdate = "event_update"
    case eventDelete = "event_delete"
    case callStart = "event_video_call_start"
}
