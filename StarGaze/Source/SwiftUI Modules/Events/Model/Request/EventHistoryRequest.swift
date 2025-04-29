//
//  EventHistoryRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 23/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct EventHistoryRequest: Encodable {
    let isActive:Bool
    let didWin: Bool
    let getTimeLine: Bool
    let isCeleb: Bool
    let start: Int
    
    enum CodingKeys: String, CodingKey {
        case isActive = "activeEvents"
        case didWin = "eventsWon"
        case getTimeLine = "videoCallHistory"
        case isCeleb = "celebHistory"
        case start = "start"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isActive ? 1 : 0, forKey: .isActive)
        try container.encode(didWin ? 1 : 0, forKey: .didWin)
        try container.encode(getTimeLine ? 1 : 0, forKey: .getTimeLine)
        try container.encode(isCeleb ? 1 : 0, forKey: .isCeleb)
        try container.encode(start, forKey: .start)
    }
}
