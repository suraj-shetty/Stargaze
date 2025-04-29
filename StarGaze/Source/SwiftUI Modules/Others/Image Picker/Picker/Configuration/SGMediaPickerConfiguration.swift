//
//  SGMediaPickerConfiguration.swift
//  PhotoLibrary
//
//  Created by Suraj Shetty on 04/07/22.
//

import Foundation

enum SGPickerMediaType {
    case images
    case videos
}

class SGMediaPickerConfiguration: NSObject {
    var selectionLimit: UInt = 2
    var types: [SGPickerMediaType] = [.images, .videos]
    var allowEditing: Bool = true
    var preselectedItems: [PLMediaItem] = []
    
    class var `default`: SGMediaPickerConfiguration {
        get {
            return SGMediaPickerConfiguration()
        }
    }
}
