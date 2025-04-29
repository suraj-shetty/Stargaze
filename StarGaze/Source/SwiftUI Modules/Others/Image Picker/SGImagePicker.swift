//
//  SGImagePicker.swift
//  StarGaze
//
//  Created by Suraj Shetty on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import YPImagePicker
import SwiftUI
import AVFoundation

public struct SGImagePicker: UIViewControllerRepresentable {
    
    private var pickedItems:[YPMediaItem]? = nil
    private let onMediaPicked: ([YPMediaItem]) -> Void
    private var maxItems:Int
    private var mediaTypes: YPlibraryMediaType = .photoAndVideo
    
    @Environment(\.dismiss) private var dismiss
    
    public init(pickedItem:[YPMediaItem]?,
                maxItems: Int = 10,
                types:YPlibraryMediaType? = nil,
                onMediaPicked: @escaping ([YPMediaItem]) -> Void) {
        self.pickedItems = pickedItem
        self.onMediaPicked = onMediaPicked
        self.maxItems = maxItems
        
        if let types = types{
            self.mediaTypes = types
        }
    }
    
    public func makeUIViewController(context: Context) -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        
        config.shouldSaveNewPicturesToAlbum = false
//        config.showsCrop = .rectangle(ratio: 1)
        config.targetImageSize = .cappedTo(size: 1080)
        config.screens = [.library]
        
        if mediaTypes == .photo || mediaTypes == .photoAndVideo {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                config.screens.append(.photo)
            }
        }
                
        if mediaTypes == .video || mediaTypes == .photoAndVideo {
            config.showsVideoTrimmer = true
            config.video.fileType = .mp4
            config.video.compression = AVAssetExportPreset1280x720
            config.video.libraryTimeLimit = 60 * 45
            config.video.recordingTimeLimit = 240
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                config.screens.append(.video)
            }
        }
        else {
            config.showsVideoTrimmer = false
        }
                
        config.library.mediaType = mediaTypes
        config.library.maxNumberOfItems = maxItems
        config.library.preselectedItems = pickedItems
        config.library.preSelectItemOnMultipleSelection = true        
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { items, cancelled in
            
            if cancelled  {
                self.dismiss()
                return
            }
            
//            var fileURLs = [URL]()
//            for item in items {
//                switch item {
//                case .photo(let photo):
//                    if let url = photo.url {
//                        fileURLs.append(url)
//                        debugPrint("Photo \(url)")
//                    }
//
//                    debugPrint(photo.exifMeta!)
////                    debugPrint(photo.)
//                case .video(let video):
//                    fileURLs.append(video.url)
//                    debugPrint("Video \(video.url)")
//                    break
//                }
//            }
            
            self.onMediaPicked(items)
            self.dismiss()
        }
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: YPImagePicker, context: Context) {
        
    }
    
    public func makeCoordinator() -> SGImagePickerCoordinator {
        SGImagePickerCoordinator {
            self.dismiss()
        } onMediaPicked: { files in
            self.onMediaPicked(files)
        }
    }
}

final public class SGImagePickerCoordinator : NSObject {
    private let onDismiss: () -> Void
    private let onMediaPicked: ([YPMediaItem]) -> Void
    
    init(onDismiss: @escaping () -> Void, onMediaPicked: @escaping ([YPMediaItem]) -> Void) {
        self.onDismiss = onDismiss
        self.onMediaPicked = onMediaPicked
    }
}


