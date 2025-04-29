//
//  NotifPayload.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 20/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum APNSType: String, Codable {
    case event = "new_event"
    case show = "new_show"
    case feed = "new_post"
    case poll = "new_poll"
    case celeb = "new_celeb"
}

struct APNSPayload: Codable, Equatable {
    let type: APNSType
    let id: String
    let notifId: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case id = "type_id"
        case notifId = "id"
    }
    
    static func == (lhs: APNSPayload, rhs: APNSPayload) -> Bool {
        return (lhs.id == rhs.id) && (lhs.type == rhs.type)
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.type = try container.decode(APNSType.self, forKey: .type)
//
//        if let id = try? container.decodeIfPresent(Int.self, forKey: .id) {
//            self.id = String(id)
//        }
//        else if let id = try? container.decodeIfPresent(String.self, forKey: .id) {
//            self.id = id
//        }
//        else {
//            self.id = ""
//        }
//    }
}

