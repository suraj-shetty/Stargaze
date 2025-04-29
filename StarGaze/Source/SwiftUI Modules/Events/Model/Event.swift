//
//  Event.swift
//  StarGaze_Test
//
//  Created by Sourabh Kumar on 27/04/22.
//

import Foundation

struct Events : Codable{
    public var result : [Event]
}

struct SingleEvent : Codable{
    public var result : Event
}


struct Event: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let status: EventStatus
    let eventType: EventType
    let mediaPath: String
    let mediaType: SGMimeType
    var likeCount: Int
    var shareCount: Int
    var commentCount: Int
    var participatesCount: Int
    let createdAt: String
    let startAt: String
    let postCount: Int
    let coins: Int
    let isCommentOn: Bool
    let isJoined: Bool
    var isLiked: Bool
    let isWinnersDeclared: Bool
    var probability: Int
    let celeb: Celeb?
    let celebId: Int
    let winners: [EventWinner]?
    
    static var mockEvents: [Event] {
        return [
//            Event(id: 10, title: "Katharine Taylor", description: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat  cupidatat non proident, sunt in culpa mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. \n\nExcepteur sint occaecat  cupidatat non proident, sunt in culpa mollit anim id est laborum.", mediaPath: "img", status: "Ongoing", mediaType: "image", likeCount: 10, shareCount: 10, commentCount: 10, participatesCount: 199, createdAt: "2022-04-28T18:18:26.462Z", postCount: 49, coins: 8, isLiked: true),
//            Event(id: 11, title: "Thomas Holland", description: "Dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempo", mediaPath: "img1", status: "Upcoming", mediaType: "image", likeCount: 110, shareCount: 210, commentCount: 1110, participatesCount: 1299, createdAt: "2022-05-30T14:28:26.462Z", postCount: 99, coins: 19, isLiked: false),
//            Event(id: 12, title: "Jessica Alba", description: "Dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempo Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat  cupidatat non proident, sunt in culpa mollit anim id est laborum. \nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat  cupidatat non proident, sunt in culpa mollit anim id est laborum.", mediaPath: "img2", status: "Upcoming", mediaType: "image", likeCount: 11, shareCount: 99, commentCount: 990, participatesCount: 88, createdAt: "2022-06-21T19:11:26.462Z", postCount: 8, coins: 5, isLiked: false)
        ]
    }
    
    // MARK: - Computed Properties
    
    var commentString: String {
        return "\(self.commentCount)"
    }
    
    var likeString: String {
        return "\(self.likeCount)"
    }
    
    var participantsString: String {
        return "\(self.participatesCount)"
    }
    
    var shareString: String {
        return "\(self.shareCount)"
    }
    
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


//Response

//      "mediaPath": "https://cdn-event-qa.stargaze.ai/img",
//      "id": 148,
//      "title": "Kathrine Taylor",
//      "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempo",
//      "winnersCount": 0,
//      "liveViewersCount": 0,
//      "wildCardReservePercentage": 10,
//      "allowedWildCardUserCount": 0,
//      "joinedWithWildCardUserCount": 0,
//      "minsPerWinner": 0,
//      "coins": 0,
//      "startAt": "2022-05-30T11:22:33.000Z",
//      "probabilityUpdateDate": "2022-05-04T18:07:08.475Z",
//      "mediaType": "image",
//      "isCommentOn": true,
//      "status": "upcoming",
//      "eventType": "event",
//      "participatesCount": 0,
//      "likeCount": 0,
//      "shareCount": 0,
//      "commentCount": 0,
//      "earnings": 0,
//      "celebEarnings": 0,
//      "stargazeEarnings": 0,
//      "opentokSessionId": null,
//      "celebStreamId": null,
//      "winnerStreamId": null,
//      "paymentStatus": "open",
//      "is10MinutesBidExpireSent": false,
//      "is5MinutesNotificationSent": false,
//      "isWinnersDeclared": false,
//      "is15MinutesNotificationSent": false,
//      "createdAt": "2022-04-27T11:23:56.221Z",
//      "updatedAt": "2022-05-04T17:07:08.475Z",
//      "celebId": 129,
//      "celeb": {
//        "name": null,
//        "picture": null
//      },
//      "eventCategory": [],
//      "isJoined": false,
//      "isLiked": false,
//      "winners": null,
//      "probability": 0,
//      "postIds": [],
//      "postCount": 0
