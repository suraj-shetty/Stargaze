//
//  SGUploadInfo.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

enum SGUploadType {
    case feed
    case event
    case profile
}

class SGUploadInfo: NSObject {
    let type:SGUploadType
    let fileURL: URL!
    let mimeType:SGMimeType
    
    init(type:SGUploadType, url:URL, mimeType:SGMimeType) {
        self.type = type
        self.fileURL = url
        self.mimeType = mimeType
    }
}
