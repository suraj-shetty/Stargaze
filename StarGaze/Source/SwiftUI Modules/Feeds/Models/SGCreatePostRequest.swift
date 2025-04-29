//
//  SGCreatePostRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 06/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

enum SGMediaAspectRatio: Codable {
    case square // "square"
    case aspect3x2 // "aspect:3x2"
    case aspect2x3
    case aspect4x3 // "aspect:4x3"
    case aspect4x5
    case aspect16x9 // "aspect:16x9"
    case aspect(width:Int, height:Int) //aspect:WxH
    case ratio(Double) //"ratio:<Double>"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
                
        switch value {
        case "square":          self = .square
        case "aspect:4x3":      self = .aspect4x3
        case "aspect:16x9":     self = .aspect16x9
        case "aspect:3x2":      self = .aspect3x2
        case "aspect:2x3":       self = .aspect2x3
        case "aspect:4x5":       self = .aspect4x5
        default:
            if value.hasPrefix("aspect:") {
                let aspectPattern = #"aspect:"# + #"(?<width>\d{1,5})"# + "x" + #"(?<height>\d{1,5})"#
                guard let matches = value.matchResult(for: aspectPattern), matches.count == 2 //Width & Height
                else {
                    self = .square //Setting a default value
                    return
                }
                
                let width = Int(matches.first!)!
                let height = Int(matches.last!)!
                
                if height == 0 || width == 0 {
                    self = .square
                }
                else {
                    self = .aspect(width: width, height: height)
                }
            }
            else if value.hasPrefix("ratio:") {
                let ratioString = value.dropFirst("ratio:".count)
                
                if let ratio = Double(ratioString) {
                    self = .ratio(ratio)
                }
                else {
                    self = .square
                }
            }
            else {
                self = .square
            }
        }
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .square:                           try container.encode("square")
        case .aspect4x3:                        try container.encode("aspect:4x3")
        case .aspect16x9:                       try container.encode("aspect:16x9")
        case .aspect3x2:                        try container.encode("aspect:3x2")
        case .aspect4x5:                        try container.encode("aspect:4x5")
        case .aspect2x3:                        try container.encode("aspect:2x3")
        case .aspect(let width, let height):    try container.encode("aspect:\(width)x\(height)")
        case .ratio(let double):                try container.encode("ratio:\(double)")
        }
    }
}

extension SGMediaAspectRatio {
    var ratio: CGFloat {
        switch self {
        case .square:                           return 1
        case .aspect4x3:                        return 1.33333 // 4/3 = 1.33333
        case .aspect16x9:                       return 1.77778 // 16/9 = 1.77778
        case .aspect3x2:                        return 1.5
        case .aspect2x3:                        return 0.6667
        case .aspect4x5:                        return 0.8
        case .aspect(let width, let height):    return CGFloat(width) / CGFloat(height)
        case .ratio(let ratio):                 return CGFloat(ratio)
        }
    }
}

extension SGMediaAspectRatio: Equatable, Hashable {
    
}

extension String { //Ref:- https://www.advancedswift.com/regex-capture-groups/#regex-capture-groups
    func matchResult(for pattern:String) -> [String]? {
        do {
            let regex       = try NSRegularExpression(pattern: pattern, options: [])
            let searchRange = NSRange(self.startIndex..<self.endIndex, in: self)
            let matches     = regex.matches(in: self, range: searchRange)
           
            guard let match = matches.first
            else { return nil }
            
            var output = [String]()
            for rangeIndex in 0..<match.numberOfRanges {
                let matchRange = match.range(at: rangeIndex)
                    
                    if matchRange == searchRange { continue }
                    
                    // Extract the substring matching the capture group
                    if let substringRange = Range(matchRange, in: self) {
                        let capture = String(self[substringRange])
                        output.append(capture)
                    }
            }
            return output
        }
        catch { } //Do nothing
        
        return nil
    }
}



struct SGPostMedia: Codable {
    let mediaType: SGMimeType
    let mediaPath: String
    
    enum CodingKeys: String, CodingKey {
        case mediaType
        case mediaPath
    }    
}


struct SGCreatePostRequest: Codable {
    let desc:String
    let events:[Event]
    let media:[SGPostMedia]
    let hashtag:String
    let allowComments:Bool
    let exclusive:Bool
    let aspectRatio:SGMediaAspectRatio
    
    enum CodingKeys: String, CodingKey {
        case desc = "description"
        case events
        case media
        case hashtag = "hashTag"
        case allowComments = "isCommentOn"
        case exclusive = "isExclusive"
        case aspectRatio = "mediaAspectRatio"
    }
}
