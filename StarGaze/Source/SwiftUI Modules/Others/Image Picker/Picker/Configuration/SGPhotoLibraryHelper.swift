//
//  SGPhotoLibraryHelper.swift
//  PhotoLibrary
//
//  Created by Suraj Shetty on 04/07/22.
//

import Foundation
import Photos

class SGPhotoLibraryHelper {
    class func requestLibraryAccess(_ completion: @escaping (Bool) -> () ) {
        let currentAccess = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        guard currentAccess != .limited && currentAccess != .authorized
        else {
            DispatchQueue.main.async {
                completion(true)
            }
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            let hasAccess = (status == .authorized) || (status == .limited)
            
            DispatchQueue.main.async {
                completion(hasAccess)
            }
        }
    }
    
    class func mediaFolder() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("photo_picker")
    }
    
    static func formattedStrigFrom(_ timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
