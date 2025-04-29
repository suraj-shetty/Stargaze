//
//  UserDetail.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct UserDetailResult: Codable {
    let result: UserDetail
}

struct UserDetail: Codable {
    let id: Int
    let name: String?
    let role: UserRole
    let mobileNumber: String
    let dialCode: String?
    let bio: String?
    let birthDate: String?
    let picture: String?
    let email: String?
    let celebrityDetail: CelebrityDetail?
    let totalFollowers: Int?
    let totalFollowings: Int?
    let totalSubscribers: Int?
    let totalVideoCalls: Int?
    let pollCount: Int?
    let totalEvents: Int?
    let earnings: Double?
    let token: String
    let socialType: SocialSignInRequest.SocialSignType?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case mobileNumber
        case dialCode = "countryCode"
        case bio
        case birthDate = "dob"
        case picture
        case email
        case celebrityDetail = "celeb"
        case totalFollowers = "followersCount"
        case totalFollowings = "followingsCount"
        case totalSubscribers = "subscribersCount"
        case totalVideoCalls = "videoCallCount"
        case pollCount
        case totalEvents = "eventCount"
        case earnings = "totalEarnings"
        case token
        case socialType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.role = try container.decode(UserRole.self, forKey: .role)
        self.dialCode = try container.decodeIfPresent(String.self, forKey: .dialCode)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)
        self.picture = try container.decodeIfPresent(String.self, forKey: .picture)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.celebrityDetail = try container.decodeIfPresent(CelebrityDetail.self, forKey: .celebrityDetail)
        self.totalFollowers = try container.decodeIfPresent(Int.self, forKey: .totalFollowers)
        self.totalFollowings = try container.decodeIfPresent(Int.self, forKey: .totalFollowings)
        self.totalSubscribers = try container.decodeIfPresent(Int.self, forKey: .totalSubscribers)
        self.totalVideoCalls = try container.decodeIfPresent(Int.self, forKey: .totalVideoCalls)
        self.pollCount = try container.decodeIfPresent(Int.self, forKey: .pollCount)
        self.totalEvents = try container.decodeIfPresent(Int.self, forKey: .totalEvents)
        self.earnings = try container.decodeIfPresent(Double.self, forKey: .earnings)
        self.token = try container.decode(String.self, forKey: .token)
        self.socialType = try container.decodeIfPresent(SocialSignInRequest.SocialSignType.self, forKey: .socialType)
        
        if let mobileNumber = try? container.decodeIfPresent(String.self, forKey: .mobileNumber) {
            self.mobileNumber = mobileNumber
        }
        else if let mobileNumber = try? container.decodeIfPresent(Int.self, forKey: .mobileNumber) {
            self.mobileNumber = "\(mobileNumber)"
        }
        else {
            self.mobileNumber = "0"
        }
        
    }
}

struct CelebrityDetail: Codable {
    let tier: String
    let status: SGCelebrityStatus
    let categories: [CelebCategory]
    
    enum CodingKeys: String, CodingKey {
        case tier
        case status
        case categories = "celebCategory"
    }
}

struct CelebCategory: Codable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
