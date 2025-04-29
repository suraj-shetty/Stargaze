//
//  EventStatus.swift
//  StarGaze
//
//  Created by Suraj Shetty on 04/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum EventStatus: String, Codable {
    case upcoming = "upcoming"
    case aboutToStart = "about_to_start"
    case started = "started"
    case ongoing = "ongoing"
    case ended = "completed"
    case cancelled = "canceled"
}
