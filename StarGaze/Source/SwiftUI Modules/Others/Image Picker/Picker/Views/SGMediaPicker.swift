//
//  SGMediaPicker.swift
//  PhotoLibrary
//
//  Created by Suraj Shetty on 04/07/22.
//

import SwiftUI
import Photos
import PhotosUI

struct SGMediaPicker: UIViewControllerRepresentable {
    let configuration: SGMediaPickerConfiguration
    
    @Binding var isPresented: Bool
    
    var onPicked: (([PLMediaItem]) -> Void)
    
//    init(configuration: SGMediaPickerConfiguration, presented: Binding<Bool>) {
//        self.configuration = configuration
//        self.isPresented = presented
//    }
    
        
    typealias UIViewControllerType = PHPickerViewController
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        let filters :[PHPickerFilter] = configuration.types.map({
            switch $0 {
            case .images: return PHPickerFilter.images
            case .videos: return PHPickerFilter.videos
            }
        })
        
        var pickerConfiguration = PHPickerConfiguration()
        pickerConfiguration.filter = .any(of: filters)
        pickerConfiguration.selectionLimit = Int(configuration.selectionLimit)
        pickerConfiguration.preselectedAssetIdentifiers = configuration.preselectedItems.map({ $0.assetID })
        pickerConfiguration.preferredAssetRepresentationMode = .current
                        
        let viewController = PHPickerViewController(configuration: pickerConfiguration)
        viewController.delegate = context.coordinator
        viewController.navigationController?.isNavigationBarHidden = true
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        uiViewController.navigationController?.isNavigationBarHidden = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    
    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: SGMediaPicker
        
        init(_ parent: SGMediaPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty
            else {
                parent.isPresented = false
                return
            }
            
            var isDirectory: ObjCBool = true
            let parentFolder = SGPhotoLibraryHelper.mediaFolder()
            if !FileManager.default.fileExists(atPath: parentFolder.absoluteString,
                                               isDirectory: &isDirectory) {
                do {
                   try FileManager.default.createDirectory(at: parentFolder,
                                                           withIntermediateDirectories: true)
                }
                catch {
                    print("Failed to create directory \(error)")
                }
            }
            
            
            var output = [PLMediaItem]()
            let group = DispatchGroup()
            
            for result in results {
                let itemProvider = result.itemProvider
                
                guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                      let utType = UTType(typeIdentifier)
                else { continue }
                
                
                if utType.conforms(to: .image) {
                    group.enter()
                    
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let error = error {
                            print("Failed to fetch image \(error)")
                        }
                        
                        else if let image = object as? UIImage {
                            let item = PLMediaItem(type: .photo(image, nil), assetID: result.assetIdentifier ?? "")
                            output.append(item)
                        }
                        else {
                            print("Is not UIImage")
                        }
                        
                        group.leave()
                    }
                }
                else if utType.conforms(to: .movie) {
                    group.enter()
                                        
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                        if let error = error {
                            print("Failed to fetch video \(error)")
                            group.leave()
                            return
                        }
                        
                        guard let url = url else {
                            print("Unknown file url")
                            group.leave()
                            return
                        }
                        
                        let fileName = UUID().uuidString
                        let targetURL = SGPhotoLibraryHelper.mediaFolder().appendingPathComponent(fileName)
                            .appendingPathExtension(for: utType)
                        
                        do {
                            try FileManager.default.copyItem(at: url, to: targetURL)
                            print("Video saved")
                            
                            let item = PLMediaItem(type: .video(targetURL, nil), assetID: result.assetIdentifier ?? "")
                            output.append(item)
                            
                        }
                        catch {
                            print("Failed to save video \(error)")
                        }
                        group.leave()
                    }
                }
                else {
                    print("Unknown file selected \(utType.description)")
                }
            }
            
            group.notify(queue: .main) {
                if output.isEmpty == false {
                    self.parent.onPicked(output)
                }
                self.parent.isPresented = false

            }
        }
    }
}

