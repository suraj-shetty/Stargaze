//
//  SGUploadData.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

enum SGMimeType: String, Codable {
    case png = "image/png"
    case jpeg = "image/jpeg"
    case jpg = "image/jpg"
    case tif  = "image/tiff"
    
    case mp4 = "video/mp4"
    case mpeg = "video/mpeg"
    case mov = "video/quicktime"
    case avi = "video/x-msvideo"
    case movie = "video/x-sgi-movie"
    case m4v = "video/x-m4v"
    
    case video = "video"
    case image = "image"
    case string = "string"
    
    case octetStream = "application/octet-stream"
    
    case unknown
    
    init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        
        if let type = SGMimeType(rawValue: label) {
            self = type
        }
        else {
            if label.hasPrefix("image") {
                self = .image
            }
            else if label.hasPrefix("video") {
                self = .video
            }
            else {
                self = .unknown
            }
        }
    }
    
    func fileExtension() -> String {
        switch self {
        case .png: return "png"
        case .jpeg, .jpg: return "jpeg"
        case .tif: return "tiff"
            
        case .mp4: return "mp4"
        case .mpeg: return "mpeg"
        case .mov: return "mov"
        case .avi: return "avi"
        case .movie: return "movie"
        case .m4v: return "m4v"
            
        case .image: return "image"
        case .video: return "video"
        case .string: return "string"
            
        case .octetStream: return "video"
            
        case .unknown: return "unknown"
        }
    }
    
    var mediaType: SGMediaType {
        switch self {
        case .png, .jpeg, .jpg, .tif:
            return .image
        case .mp4, .mpeg, .mov, .avi, .movie, .m4v:
            return .video
            
        case .video:
            return .video
            
        case .image:
            return .image
            
        case .octetStream:
            return .video
            
        case .string, .unknown:
            return .unknown
        }
    }
}



class SGUploadData: NSObject, Codable {
    var type:SGMimeType
    var name:String
    var size:Double
    var subPath:String
    
    enum CodingKeys: String, CodingKey {
        case type = "mimetype"
        case name = "originalname"
        case size
        case subPath = "key"
    }
}
