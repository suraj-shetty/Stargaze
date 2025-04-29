//
//  VideoCallRoom.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct VideoCallRoom: Identifiable {
    let id: String = UUID().uuidString
    let eventID: Int
    let celebrityID: Int
    let userID: Int
    let userToken: String
    let canBroadcast: Bool
    let event: Event
    var isCelebrity: Bool {
        get { return celebrityID == userID }
    }
}
