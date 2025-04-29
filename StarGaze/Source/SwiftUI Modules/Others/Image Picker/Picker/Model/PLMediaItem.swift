//
//  PLImageItem.swift
//  PhotoLibrary
//
//  Created by Suraj Shetty on 05/07/22.
//

import Foundation
import UIKit


enum PLMediaType {
    case photo(UIImage, UIImage?)
    case video(URL, URL?)
}

class PLMediaItem: NSObject, Identifiable {
    let type: PLMediaType
    var assetID: String
    var id: String
    
    init(type: PLMediaType, assetID: String) {
        self.id = UUID().uuidString
        self.assetID = assetID
        self.type = type
    }
}

//class PLImageItem: NSObject, PLMediaItem {
//    let image:UIImage!
//
//    init(image: UIImage) {
//        self.image = image
//    }
//}
//
//class PLVideoItem: NSObject, PLMediaItem {
//    let videoURL:URL!
//
//    init(url: URL) {
//        self.videoURL = url
//    }
//}

