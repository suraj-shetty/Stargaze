//
//  SGCreateFeedViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 03/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import YPImagePicker
import Combine
import SwiftUI

class SGCreateFeedAttachment: NSObject, ObservableObject, Identifiable {
    var uploadResponse:SGUploadResult?
    var item: YPMediaItem!
    
    @Published var canPlay: Bool = false
    
    private(set) var mimeType:SGMimeType!
    private(set) var fileURL:URL?
    
    let uuid:String = UUID().uuidString
    var id: String!
    
    init(item:YPMediaItem, completion: @escaping ()->()) {
        super.init()
        
        self.item = item
        self.id = uuid
        
        switch item {
        case .photo(let photo):
            let image = photo.image
            if let data = image.pngData() {
                self.mimeType = .png
                
                let fileName = "\(uuid).png"
                self.save(data: data, fileName: fileName) { didSave, url in
                    if didSave {
                        self.fileURL = url
                    }
                    completion()
                }
                                
            }
            else if let data = image.jpegData(compressionQuality: 1) {
                self.mimeType = .jpeg
                
                let fileName = "\(uuid).jpeg"
                self.save(data: data, fileName: fileName) { didSave, url in
                    if didSave {
                        self.fileURL = url
                    }
                    completion()
                }
                
            }
            
        case .video(let video):
            self.mimeType = .mp4
            self.fileURL = video.url
            completion()
//            video.fetchData {[weak self] videoData in
//                guard let ref = self else {
////                    completion()
//                    return
//                }
//                
//                let fileName = "\(ref.uuid).mp4"
//                ref.save(data: videoData, fileName: fileName) {[weak ref] didSave, url in
//                    if didSave {
//                        ref?.fileURL = url
//                    }
//                    
//                    completion()
//                }                                                
//            }
        }
    }
    
    static func == (lhs: SGCreateFeedAttachment, rhs: SGCreateFeedAttachment) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    override var hash: Int {
        return uuid.hash
    }
}


private extension SGCreateFeedAttachment {
    func save(data:Data, fileName:String, completion: @escaping (Bool,URL?) -> Void){
        
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(fileName)
        let fileURL = URL(fileURLWithPath: filePath)
                            
        let fileManager = FileManager.default
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async {
            //write to URL atomically
            do {
                try data.write(to: fileURL, options: .atomic)
                if fileManager.fileExists(atPath: filePath) {
                    completion (true, fileURL)
                }
                else {
                    completion (false,fileURL)
                }
            }
            catch {
                completion (false,fileURL)
            }
        }
    }
}


class SGCreateFeedViewModel: ObservableObject {
    @Published var desc:String = ""
    @Published var isExclusive:Bool = false
    @Published var disableComment:Bool = false
    @Published var items:[SGCreateFeedAttachment] = []
    
    @Published var didPost:Bool = false
    @Published var hasError:Bool = false
    @Published var isLoading:Bool = false
    
    @Published var aspectRatio:SGMediaAspectRatio = .square
    
    private(set) var error:SGAPIError? = nil
    {
        didSet {
            hasError = (error != nil)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func canPost() -> Bool {
        guard desc.isEmpty == false
        else {
            self.error = SGAPIError.custom(NSLocalizedString("create-feed.description.empty.message", comment: ""))
            return false
        }
        
        return true
    }
    
    func post() {
        guard desc.isEmpty == false
        else {
            self.error = SGAPIError.custom(NSLocalizedString("create-feed.description.empty.message", comment: ""))
            return
        }
        
        let request = FeedUploadRequest(desc: desc,
                                        isExclusive: isExclusive,
                                        disableComments: self.disableComment,
                                        attachments: items,
                                        aspectRatio: aspectRatio)
        FeedUploadManager.shared
            .submitFeed(request)
//        return
        
        
//        isLoading = true
//
//        let pendingItems = items.filter({ $0.uploadResponse == nil && $0.fileURL != nil })
//        if !pendingItems.isEmpty {
//            let mergedUploads = upload(attachments: pendingItems)
//
//            mergedUploads
//                .sink { result in
//                    switch result {
//                    case .failure(let error):
//                        self.error = error
//                        self.isLoading = false
////                        self.hasError = true
//                        debugPrint("Upload error \(error)")
//                    case .finished:
//                        debugPrint("Upload Complete")
//                    }
//                } receiveValue: {[weak self] _ in
//                    self?.submitPost()
//                }
//                .store(in: &cancellables)
//        }
//
//        else {
//            submitPost()
//        }
    }
    
    func deleteAttachment(_ attachment: SGCreateFeedAttachment) {
        if let index = items.firstIndex(of: attachment) {
            let discardedItem = items.remove(at: index)
            discardedItem.canPlay = false
        }
    }
    
    //MARK: -
    private func submitPost() {
        debugPrint("Post to submit")
        SGFeedService.createPost(request: self.createPostRequest())
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
//                        self.hasError = true
                        self.isLoading = false
                        debugPrint("Post submit error \(error)")
                    }
                    break
                case .finished:
                    self.isLoading = false
                    debugPrint("Post submitted")
                    break
                }
            } receiveValue: { didPost in
                if didPost {
                    self.error = nil
                    self.didPost = true                    
                }
            }
            .store(in: &cancellables)
    }
    
    private func createPostRequest() -> SGCreatePostRequest {
        let mediaItems = self.items
            .filter{ $0.uploadResponse != nil }
            .map { attachment -> SGPostMedia in
                
                let uploadResponse = attachment.uploadResponse!
                let data = uploadResponse.data
                
                let media = SGPostMedia(mediaType: data.type,
                                        mediaPath:data.subPath)
                
                return media
                
            }
        
        
        let request = SGCreatePostRequest(desc: desc,
                                          events: [],
                                          media: mediaItems,
                                          hashtag: "",
                                          allowComments: !disableComment,
                                          exclusive: isExclusive,
                                          aspectRatio: aspectRatio)
        return request
    }
    
    private func upload(attachments:[SGCreateFeedAttachment]) -> AnyPublisher<[SGCreateFeedAttachment], SGAPIError> {
        let publishers =  attachments.map({ attachment in
            upload(item: attachment)
        })
        
        let subject:PassthroughSubject<[SGCreateFeedAttachment], SGAPIError> = .init()
        
        Publishers.MergeMany(publishers)
            .collect()
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    subject.send(completion: .failure(error))
                    
                case .finished:
                    debugPrint("Multiple upload complete")
                    subject.send(completion: .finished)
                }
            }, receiveValue: { value in
                subject.send(value)
            })
            .store(in: &cancellables)
            
        return subject.eraseToAnyPublisher()
    }
    
    private func upload(item:SGCreateFeedAttachment) -> AnyPublisher<SGCreateFeedAttachment, SGAPIError> {
        let info = SGUploadInfo(type: .feed,
                                url: item.fileURL!,
                                mimeType: item.mimeType)
        
        let subject:PassthroughSubject<SGCreateFeedAttachment, SGAPIError> = .init()
        SGUploadManager.shared.upload(info: info)
            .sink { result in
                switch result {
                case .failure(let error):
                    subject.send(completion: .failure(error))

                case .finished:
                    debugPrint("Single Upload complete")
                    subject.send(completion: .finished)
                    break
                }
            } receiveValue: { value in
                item.uploadResponse = value
                subject.send(item)
//                switch value {
//                case .response(let result):
//                    item.uploadResponse = result
//                    subject.send(item)
//
//                case .progress(let progress):
//                    debugPrint("Upload progress \(progress)")
//                }
            }
            .store(in: &cancellables)

        return subject.eraseToAnyPublisher()
    }
}
