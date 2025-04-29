//
//  SocketModel.swift
//  StargazeSocket
//
//  Created by Suraj Shetty on 10/08/22.
//

import Foundation

//struct CallEventInfo {
//    let eventId: String
//    let callToken: String
//    let sessionID: String
//}

struct CallReadyInfo {
    let eventID: String
}

//struct CallWinnerInfo {
//    let eventID: String
//    var shouldConnect: Bool
//    let winnerStreamID: String
//    let pendingDuration: TimeInterval
//}

struct CallUpdateInfo {
    let eventID: String
    let celebStreamID: String
    let winnerStreamID: String
}

struct CallUserLeftInfo {
    let eventID: String
}



struct CallResponse<T: Codable>: Codable {
    let result: T
}

struct CallViewerCount: Codable {
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case count = "viewerCount"
    }
}

struct CallUser: Codable {
    let id: Int
    let name: String?
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userName = "username"
    }
}

struct CallWinner: Codable {
    let eventID: Int
    let id: Int
    let userID: Int
    let user: CallUser
    let position: Int
    let totalDuration: TimeInterval
    let leftDuration: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case id
        case userID = "winnerUserId"
        case user
        case position
        case totalDuration = "winnerCallDuration"
        case leftDuration = "winnerPendingCallDuration"
    }
}

struct CallDetails: Codable {
    let eventID: String
    let sessionID: String
    let sessionToken: String
    let winners: [CallWinner]
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case sessionID = "opentokSessionId"
        case sessionToken = "token"
        case winners = "eventWinners"
    }
}

struct CallInfo: Codable {
    let eventID: String
    let isSubscriber: Bool
    let sessionID: String
    let sessionToken: String
    let winnerID: String?
    let celebID: String?
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case isSubscriber
        case sessionID = "opentokSessionId"
        case sessionToken = "token"
        case winnerID = "winnerStreamId"
        case celebID = "celebStreamId"
    }
}

struct CallJoinInfo: Codable {
    let eventID: String
     let connect: Bool
//
// shouldConnect: Bool {
///        get { return connect == 1 }
//    }
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case connect
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let eventId = try? container.decode(Int.self, forKey: .eventID) {
            self.eventID = "\(eventId)"
        }
        else if let eventId = try? container.decode(String.self, forKey: .eventID) {
            self.eventID = eventId
        }
        else {
            self.eventID = ""
        }
        self.connect = try container.decode(Bool.self, forKey: .connect)
    }        
}

struct CallJoinedInfo: Codable {
    let eventID: Int
    let canConnect: Bool
    let pendingDuration: TimeInterval
    let winnerID: String
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case canConnect = "connect"
        case pendingDuration = "winnerPendingCallDuration"
        case winnerID = "winnerStreamId"
    }
}

struct CallPassInfo: Codable {
    let sessionID: String
    let sessionToken: String
    let pendingDuration: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "opentokSessionId"
        case sessionToken = "token"
        case pendingDuration = "winnerPendingCallDuration"
    }
}

struct CallEventInfo: Codable {
    let eventID: String
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
    }
}

struct CallEventCompleteInfo: Codable {
    let eventID: Int
    let status: Bool
    
    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case status
    }
}
