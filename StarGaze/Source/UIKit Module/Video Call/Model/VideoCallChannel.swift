//
//  VideoCallChannel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct VideoCallChannel {
    let id: String
    let token: String
}

extension VideoCallChannel: Equatable, Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.id == rhs.id) && (lhs.token == rhs.token)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(token)
    }
}
