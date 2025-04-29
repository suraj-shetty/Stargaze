//
//  SGUploadResult.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGUploadResult: NSObject, Codable {
    var data:SGUploadData
    var filePath:String
    
    enum CodingKeys: String, CodingKey {
        case data
        case filePath = "cdn"
    }
}
