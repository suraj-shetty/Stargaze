//
//  FeedUploadManager.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct FeedUploadRequest {
    let desc: String!
    let isExclusive: Bool
    let disableComments: Bool
    let attachments: [SGCreateFeedAttachment]?
    let aspectRatio: SGMediaAspectRatio
}

enum FeedUploadState {
    case none
    case fileUpload
    case postCreate
    case failed
}

extension FeedUploadState {
    var title: String {
        switch self {
        case .none:
            return ""
        case .fileUpload:
            return "Uploading files"
        case .postCreate:
            return "Creating your post"
        case .failed:
            return "Failed to create your post"
        }
    }
}


class FeedUploadManager: ObservableObject {
    static let shared = FeedUploadManager()
        
    private(set) var request: FeedUploadRequest? = nil {
        didSet {
            withAnimation {
                self.hasRequest = (request != nil)
            }
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    @Published var error: SGAPIError?
    @Published var state: FeedUploadState = .none
    @Published var hasRequest: Bool = false
    
    func submitFeed(_ request: FeedUploadRequest) {
        self.request = request
        self.initiateUpload()
    }
    
    func retry() {
        self.initiateUpload()
    }
    
    private func initiateUpload() {
        guard let request = request
        else { return }
        
        let pendingItems = request.attachments?
            .filter({ $0.uploadResponse == nil && $0.fileURL != nil })
        
        if let pendingItems = pendingItems, !pendingItems.isEmpty {
            self.state = .fileUpload
            
            let mergedUploads = upload(attachments: pendingItems)
            mergedUploads
                .sink { result in
                    switch result {
                    case .failure(let error):
                        self.error = error
                        self.state = .failed
//                        self.hasError = true
                        debugPrint("Upload error \(error)")
                    case .finished:
                        debugPrint("Upload Complete")
                    }
                } receiveValue: {[weak self] _ in
                    self?.submitPost()
                }
                .store(in: &cancellables)
        }
        else {
            self.submitPost()
        }

    }
    
    private func submitPost() {
        guard let request = self.createPostRequest()
        else { return }
        
        debugPrint("Post to submit")
        self.state = .postCreate
        SGFeedService.createPost(request: request)
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                        self.state = .failed
//                        self.hasError = true
//                        self.isLoading = false
                        debugPrint("Post submit error \(error)")
                    }
                    break
                case .finished:
//                    self.isLoading = false
                    debugPrint("Post submitted")
                    break
                }
            } receiveValue: { didPost in
                if didPost {
                    self.error = nil
                    self.request = nil
                    self.state = .none
                    NotificationCenter.default.post(name: .feedPosted, object: nil)
//                    self.didPost = true
                }
                else {
                    self.state = .failed
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Post Create Request
    private func createPostRequest() -> SGCreatePostRequest? {
        guard let uploadRequest = self.request
        else { return nil }
        
        let mediaItems = uploadRequest.attachments?
            .filter{ $0.uploadResponse != nil }
            .map { attachment -> SGPostMedia in
                
                let uploadResponse = attachment.uploadResponse!
                let data = uploadResponse.data
                
                let media = SGPostMedia(mediaType: data.type,
                                        mediaPath:data.subPath)
                
                return media
                
            }
        
        let request = SGCreatePostRequest(desc: uploadRequest.desc,
                                          events: [],
                                          media: mediaItems ?? [],
                                          hashtag: "",
                                          allowComments: !uploadRequest.disableComments,
                                          exclusive: uploadRequest.isExclusive,
                                          aspectRatio: uploadRequest.aspectRatio)
        return request
    }
    
    //MARK: - Image Upload
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
