//
//  EventRequest.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct EventCreateRequest: Codable {
    let title: String
    let description: String
    let mediaPath: String
    let mediaType: String
    let winnersCount: Int
    let minsPerWinner: Int
    let coins: Int
    let startAt: String
    let isCommentOn: Bool
}
