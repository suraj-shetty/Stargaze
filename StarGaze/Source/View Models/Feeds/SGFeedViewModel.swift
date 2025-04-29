//
//  SGFeedViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 19/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import SwiftDate
import KMBFormatter
import RxSwift
import RxRelay
import RxCocoa
import Combine
import FirebaseDynamicLinks

class SGFeedViewModel: ObservableObject, Equatable, Hashable, Identifiable {
    private(set) var feed:Post
    var canPlay = BehaviorRelay<Bool>(value: false)
    
    var isMyFeed: Bool = false
    
    @Published var descExpand:Bool = false
    @Published var isLiked:Bool = false
    @Published var likeCount:Int64 = 0
    @Published var commentCount:Int64 = 0
    @Published var shareCount:Int64 = 0
    
    @Published var allowPlaying:Bool = false {
        didSet {
            self.playPauseMedia()
        }
    }
    @Published var shouldSubscribe: Bool = true
    
    @Published var currentMediaIndex: Int = 0 {
        willSet {
            self.playMedia(at: newValue)
        }
    }
    
    @Published var isDeleting: Bool = false
    @Published var error: SGAPIError? = nil
    @Published var linkGenerating: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(with feed: Post) {
        self.feed = feed
        self.isLiked = feed.isLiked ?? false
        self.likeCount = Int64(feed.likeCount)
        self.commentCount = Int64(feed.commentCount)
        self.shareCount = Int64(feed.shareCount)
        
        if let userID = SGAppSession.shared.user.value?.id, userID == feed.celeb?.id {
            self.isMyFeed = true
        }
        else {
            self.isMyFeed = false
        }                
    }
    
    deinit {
        cancellables.forEach{ $0.cancel() }
    }
    
    var id:Int {
        get { return feed.id }
    }
    
    lazy var hasMedia: Bool = {
        
        let filtered = feed.media.filter({ $0.mediaType.mediaType != .unknown })
        return !filtered.isEmpty
    }()
    
    var hasVideos:Bool {
        get {
            let videos = media.filter({ $0.type == .video })
            return !videos.isEmpty
        }
    }
    
    var allowComments: Bool {
        get { feed.isCommentOn }
    }
    
    var mediaApectRatio:SGMediaAspectRatio {
        get {
            return feed.aspectRatio ?? .square
        }
    }
    
    var hashtags: [String] {
        get {
            if (feed.postHashTag == nil || (feed.postHashTag)!.isEmpty) {
                return []
            }
            
            let validHashtags = feed.postHashTag!.filter({ ($0.name != nil) && ($0.name!.isEmpty == false) })
            return validHashtags.map({ $0.name! })
        }
    }
    
    var celebID: Int? {
        get { return feed.celeb?.id }
    }
    
    var name:String {
        get { return feed.celeb?.name ?? "" }
    }
    
    var profileImageURL: URL? {
        if let imagePath = feed.celeb?.picture, let url = URL(string: imagePath) {
            return url
        }
        else {
            return nil
        }
    }
    
    var relativeDate:String {
        get { return feed.createdAt.toDate()?.toRelative(since: nil,
                                                         dateTimeStyle: .numeric,
                                                         unitsStyle: .abbreviated) ?? "" }
    }
    
    var title:String {
        get { return feed.description ?? "" }
    }
    
//    var isLiked:Bool {
//        get { return feed.isLiked ??  false }
//    }
//    
//    var likeCount:String {
//        get { return SGFeedViewModel.numberFormatter.string(fromNumber: Int64(feed.likeCount))}
//    }
//    
//    var commentCount:String {
//        get { return }
//    }
//    
//    var shareCount:String {
//        get { return }
//    }

    lazy var media: [SGMediaViewModel] = {
        let mediaList = feed.media.map({ return SGMediaViewModel($0) })
        let filtered =  mediaList.filter( { $0.type != .unknown })
        return filtered
    }()
    
    func playMedia(at index:Int) {
        guard hasMedia else { return }
        
        let range = 0..<media.count
        
        guard range.contains(index)
        else { return }
                        
        if index != currentMediaIndex,
           range.contains(currentMediaIndex) {
            media[currentMediaIndex].playMedia = false
        }
        media[index].playMedia = allowPlaying
    }
    
    func playPauseMedia() {
        guard hasMedia else { return }
        
        if !allowPlaying {
            media.forEach({ $0.playMedia = false })
        }
        else {
            playMedia(at: currentMediaIndex)
        }
    }
    
    func edit() {
        
    }
    
    func report() {
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(feed.id)
    }
    
    static func ==(lhs: SGFeedViewModel, rhs: SGFeedViewModel) -> Bool {
        return lhs.feed.id == rhs.feed.id
    }
}

private extension SGFeedViewModel {
    func update(with feed:Post) {
        
        self.feed = feed
        self.isLiked = feed.isLiked ?? false
        self.likeCount = Int64(feed.likeCount)
        self.commentCount = Int64(feed.commentCount)
        self.shareCount = Int64(feed.shareCount)
    }
}

extension SGFeedViewModel {
        
    func toggleLike() {
        switch isLiked {
        case false:
            isLiked = true
            likeCount += 1
            
        case true:
            isLiked = false
            likeCount -= 1
        }
             
        //Calling API calls to
        SGFeedService.likeFeed(feed: self.feed)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.showErrorAlert(NSLocalizedString("feed.list.like.failed.title", comment: ""),
                                                  message: error.description)
                    
                    
                case .finished: break
                }
            }, receiveValue: { didPostLike in
                
            })
            .store(in: &cancellables)
        
        
//            .flatMap {[unowned self] _ in
//                return SGFeedService.getFeed(id: self.feed.id)
//            }
//            .sink {result in
//                switch result {
//                case .failure(let error):
//                    SGAlertUtility.showErrorAlert(NSLocalizedString("feed.list.like.failed.title", comment: ""),
//                                                  message: error.description)
//
//                case .finished: debugPrint("Feed like successfully")
//                }
//            } receiveValue: {[weak self] updatedFeed in
//                self?.update(with: updatedFeed)
//            }
//            .store(in: &cancellables)
    }
    
    func incrementShare() {
        shareCount += 1
        
        SGFeedService.shareFeed(feed: feed)
            .sink { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    SGAlertUtility.showErrorAlert(message: error.description)
                }
            } receiveValue: { didShare in
                
            }
            .store(in: &cancellables)
        
    }
    
    func delete() {
        self.isDeleting = true
        
        SGFeedService.delete(feed)
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    self?.isDeleting = false
                    SGAlertUtility.showErrorAlert(NSLocalizedString("feed.delete.error.title", comment: ""),
                                                  message: error.description)
                }
            } receiveValue: {[weak self] didDelete in
                guard let ref = self else { return }
                
                ref.isDeleting = false
                if didDelete {
                    let info = [FeedNotificationKey.listUpdateType : FeedListUpdateType.delete(ref.id)]
                    
                    NotificationCenter.default.post(name: .feedListUpdated,
                                                    object: nil,
                                                    userInfo: info)
                }
                else {
                    SGAlertUtility.showErrorAlert(NSLocalizedString("feed.delete.error.title", comment: ""), message: nil)
                }
            }
            .store(in: &cancellables)
    }
    
    func block() {
        guard let celebID = self.celebID
        else { return }
        
        SGAlertUtility.showHUD()
        SGUserService.block(userID: "\(celebID)")
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    self?.error = error
                }
            } receiveValue: {[weak self] didBlock in
                SGAlertUtility.hidHUD()
                if didBlock {
                    let info = [AppUpdateNotificationKey.updateType: AppUpdateType.celebBlocked(celebID)]
                    NotificationCenter.default.post(name: .celebrityBlocked,
                                                    object: nil,
                                                    userInfo: info)
                }
                else {
                    self?.error = SGAPIError.custom("Failed to block the user. Try again later.")
                }
            }
            .store(in: &cancellables)

    }
}

extension SGFeedViewModel {
    func shareLink(_ completion: @escaping (URL?)->()) {
        
        guard var basePath = URL(string: "https://stargazeevent.page.link/feeds")
        else {
            completion(nil)
            return
        }
        
        if #available(iOS 16.0, *) {
            basePath.append(component: "\(self.id)")
        } else {
            // Fallback on earlier versions
            basePath.appendPathComponent("\(self.id)")
        }
        let prefix = "https://stargazeevent.page.link"
        
        let linkBuilder = DynamicLinkComponents(link: basePath,
                                                domainURIPrefix: prefix)
        
        //Metadata
        let metaData = DynamicLinkSocialMetaTagParameters()
        metaData.title = feed.celeb?.name
        metaData.descriptionText = feed.description
        
        if !feed.isExclusive, let url = feed.media.first?.mediaPath.url {
            metaData.imageURL = url
        }
        
        //iOS Parameter
        if let bundleID = Bundle.main.bundleIdentifier, !bundleID.isEmpty {
            let iOSParameter = DynamicLinkIOSParameters(bundleID: bundleID)
//            iOSParameter.minimumAppVersion = Bundle.main.releaseVersionNumber
            
            #if PROD
            iOSParameter.appStoreID = "1573361691"
            #else
            iOSParameter.appStoreID = "1645083991"
            #endif
            
            linkBuilder?.iOSParameters = iOSParameter
        }
        
        let navigationInfoParameter = DynamicLinkNavigationInfoParameters()
        navigationInfoParameter.isForcedRedirectEnabled = true
//        let androidParameters = DynamicLinkAndroidParameters(packageName: "com.stargaze")
//        androidParameters.minimumVersion = 1
                
        linkBuilder?.socialMetaTagParameters = metaData
        linkBuilder?.navigationInfoParameters = navigationInfoParameter
//        linkBuilder?.androidParameters = androidParameters
        
//        guard let shareURL = linkBuilder?.url
//        else {
//            completion(nil)
//            return
//        }
           
        
        linkGenerating = true
        linkBuilder?.shorten(completion: {[weak self] url, warnings, error in
            self?.linkGenerating = false
            if let url = url {
                completion(url)
            }
            else {
                self?.error = .custom("Failed to generate share link")
                print("Feed share link failed \(error?.localizedDescription ?? "")")
            }
        })
    }
}
