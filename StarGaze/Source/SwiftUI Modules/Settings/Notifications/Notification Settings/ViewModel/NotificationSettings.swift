//
//  NotificationSettings.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 04/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

class NotificationSettings: ObservableObject, Codable {
    @Published var isOn: Bool = false
    @Published var commentsOn: Bool = true
    @Published var videosOn: Bool = true
    @Published var eventsOn: Bool = true
    @Published var activitiesOn: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case isOn = "pushNotification"
        case commentsOn = "commentNotification"
        case videosOn = "videoCallNotification"
        case eventsOn = "eventNotification"
        case activitiesOn = "moreActivitiesNotification"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(isOn, forKey: .isOn)
        try container.encode(commentsOn, forKey: .commentsOn)
        try container.encode(videosOn, forKey: .videosOn)
        try container.encode(eventsOn, forKey: .eventsOn)
        try container.encode(activitiesOn, forKey: .activitiesOn)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isOn    = try container.decode(Bool.self, forKey: .isOn)
        
        commentsOn    = try container.decode(Bool.self, forKey: .commentsOn)
        videosOn      = try container.decode(Bool.self, forKey: .videosOn)
        eventsOn      = try container.decode(Bool.self, forKey: .eventsOn)
        activitiesOn  = try container.decode(Bool.self, forKey: .activitiesOn)
    }
    
    init() {}
    
    func update(with settings: NotificationSettings) {
        self.isOn = settings.isOn
        self.commentsOn = settings.commentsOn
        self.videosOn = settings.videosOn
        self.eventsOn = settings.eventsOn
        self.activitiesOn = settings.activitiesOn
    }
}

extension NotificationSettings: Equatable {
    static func == (lhs: NotificationSettings, rhs: NotificationSettings) -> Bool {
        let isOn                = lhs.isOn == rhs.isOn
        let commentsEnabled     = lhs.commentsOn == rhs.commentsOn
        let videoCallEnabled    = lhs.videosOn == rhs.videosOn
        let eventsEnabled       = lhs.eventsOn == rhs.eventsOn
        let activitiesEnabled   = lhs.activitiesOn == rhs.activitiesOn
        return isOn && commentsEnabled && videoCallEnabled && eventsEnabled && activitiesEnabled
    }
    
    
}

class NotificationSettingResult: Codable {
    let result: NotificationSettings
}
