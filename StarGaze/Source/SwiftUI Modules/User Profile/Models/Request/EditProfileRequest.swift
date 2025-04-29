//
//  EditProfileRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 02/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct EditProfileRequest: Codable {
    var name: String?
    var bio: String?
    var email: String?
    var picture: String?
}
