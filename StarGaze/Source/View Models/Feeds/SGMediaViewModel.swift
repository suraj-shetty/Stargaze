//
//  SGMediaViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 22/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

public enum SGMediaType: Int {
    case video
    case image
    case unknown
}

class SGMediaViewModel: ObservableObject {
    @Published var playMedia: Bool = false
 
    private let media:Media
    var id:Int {
        get { return media.id }
    }
    
    var type:SGMediaType {
        guard let mediaType = media.mediaType
        else { return .unknown }
        
        switch mediaType {
        case .jpeg, .jpg, .png, .tif: return .image
        case .mp4, .movie, .mov, .avi, .mpeg, .m4v: return .video
            
        case .image: return .image
        case .video: return .video
            
        case .octetStream: return .video
            
        case .string, .unknown: return .unknown
        }
    }
    
    var url:URL? {
        guard let mediaPath = media.mediaPath, mediaPath.isEmpty == false
        else { return nil }
        
        return URL(string: mediaPath)
    }
    
    
    init(_ media:Media) {
        self.media = media
    }
}
