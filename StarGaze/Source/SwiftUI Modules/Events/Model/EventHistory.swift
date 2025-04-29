//
//  EventHistory.swift
//  StarGaze
//
//  Created by Suraj Shetty on 23/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct EventHistoryResult: Codable {
    let result: [EventHistory]
}

struct EventHistory: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let status: EventStatus
    let eventType: EventType
    let mediaPath: String
    let mediaType: SGMimeType
    let createdAt: String
    let startAt: String
    let celeb: Celeb?
    let celebId: Int
        
    // MARK: - Computed Properties
    var startDate: Date {
        let serverFormatter = ISO8601DateFormatter()
        serverFormatter.formatOptions.insert([.withInternetDateTime, .withFractionalSeconds])
        
        let date = serverFormatter.date(from: self.startAt)
        return date ?? Date()
    }
    
    var displayDate: String {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM dd 'at' hh:mm a"
        return monthFormatter.string(from: self.startDate)
    }
}
