//
//  FeedListViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 27/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import SwiftDate

class FeedListViewModel: ObservableObject {
    
    private var type: SGFeedType = .myFeeds
    private var userID: String? = nil
    private var filters: [SGFilter] = []
    
    private(set) var category: SGFeedCategory = .generic
    private(set) var scrollTracker:ListScrollTracker!
    private(set) var shouldAutoRefresh: Bool = false
    
    private let pageSize: Int = 10
    private let refreshInterval: Int = 30
    private var cancellables = Set<AnyCancellable>()
    private var currentToken: String? = nil
    private var pageStart: Int = 0
    
    private var currentItemCancellable: AnyCancellable?
    private var feedRefreshCancellable: AnyCancellable?
    private var feedListUpdateCancellable: AnyCancellable?
    private var subscriptionUpdateCancellable: AnyCancellable?
    
    private var notificationSubscribers = Set<AnyCancellable>()
    
    private var newFeeds = [SGFeedViewModel]()
    private var autoRefreshTimer: DispatchSourceTimer?
    private var autoRefreshQueue: DispatchQueue?
    
    var feeds = [SGFeedViewModel]()
    var didEnd: Bool = false
    var isLoading: Bool
    var error: SGAPIError?
    @Published var newPostAvailable: Bool = false
    
    @Published var playableFeedIndex:Int?
    
    init(for userID:String?, type:SGFeedType, category:SGFeedCategory, filters: [SGFilter] = [], autoRefresh: Bool = false) {
        self.type = type
        self.category = category
        self.userID = userID
        self.filters = filters
        
        self.didEnd = false
        self.isLoading = false
        self.error = nil
        self.playableFeedIndex = nil
        self.shouldAutoRefresh = autoRefresh
        
        self.scrollTracker = ListScrollTracker()
        self.currentItemCancellable = self.scrollTracker
            .centeredElementPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in
                self?.playFeedAtIndex($0)
            }
        
        self.subscriptionUpdateCancellable = SGAppSession.shared.subscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] subscriptions in
                guard let ref = self
                else { return }
                
                ref.updateStatus(of: ref.feeds, with: subscriptions)
                ref.updateStatus(of: ref.newFeeds, with: subscriptions)
            })
        
        NotificationCenter.default
            .publisher(for: .celebrityBlocked)
            .sink { [weak self] notification in
                let userInfo = notification.userInfo
                if let type = userInfo?[AppUpdateNotificationKey.updateType] as? AppUpdateType {
                    self?.handleUpdate(type: type)
                }
            }
            .store(in: &notificationSubscribers)
        
        NotificationCenter.default
            .publisher(for: .feedListUpdated)
            .sink(receiveValue: {[weak self] notification in
                let userInfo = notification.userInfo
                if let type = userInfo?[FeedNotificationKey.listUpdateType] as? FeedListUpdateType {
                    self?.handleListUpdate(type: type)
                }
            })
            .store(in: &notificationSubscribers)
        
        NotificationCenter.default
            .publisher(for: .feedPosted)
            .sink {[weak self] _ in
                self?.checkForNewPosts()
            }
            .store(in: &notificationSubscribers)
        
//        NotificationCenter.default
//            .publisher(for: .logout)
//            .sink {[weak self] _ in
//                self?.stopAutoRefresh()
//            }
//            .store(in: &notificationSubscribers)
    }
    
    deinit {
        /*
            If the timer is suspended, calling cancel without resuming
            triggers a crash. This is documented here
            https://forums.developer.apple.com/thread/15902
            */
                
//        autoRefreshTimer?.resume()
        autoRefreshTimer?.cancel()
        autoRefreshTimer?.setEventHandler(handler: {})
        
        cancellables.forEach{ $0.cancel() }
        cancellables.removeAll()
        
        currentItemCancellable?.cancel()
        currentItemCancellable = nil
        
        notificationSubscribers.forEach({ $0.cancel() })
        notificationSubscribers.removeAll()
    }
    
    func pauseAllVideos() {
        for feed in feeds {
            feed.canPlay.accept(false)
            feed.allowPlaying = false
        }
    }
    
    func playVisibleVideo() {
        if let playableFeedIndex = playableFeedIndex, playableFeedIndex >= 0, playableFeedIndex < feeds.count {
            playFeedAtIndex(playableFeedIndex)
        }
    }
    
    func playFeedAtIndex(_ index:Int) {
        if let lastIndex = playableFeedIndex, lastIndex < feeds.count {
            let feed = feeds[lastIndex]
            feed.allowPlaying = false
        }
        
        if index < feeds.count {
            let feed = feeds[index]
            feed.allowPlaying = true
            
            self.playableFeedIndex = index
        }
    }
    
    func fetchFeeds(shouldRefresh:Bool, completion: (()->())? = nil) {
        if shouldRefresh == true {
            didEnd = false
            cancellables.forEach({ $0.cancel() })
            cancellables.removeAll()
            
            pauseAutoRefresh()
            newFeeds.removeAll()
            
            withAnimation {
                self.newPostAvailable = false
            }
        }
        else if didEnd || isLoading { //didEnd :Already reached the end, no more request required
            //isLoading: Has previous request so ignore new calls
            completion?()
            return
        }
        
        var filterList: String? = nil
        if !filters.isEmpty {
            let nameList = filters.map({ $0.name! })
            filterList = nameList.joined(separator: ",")
        }
        
        let request = SGFeedRequest(pageToken: shouldRefresh ? nil : currentToken,
                                    pageStart: shouldRefresh ? 0 : pageStart,
                                    limit: pageSize,
                                    filters: filterList,
//                                    category: category,
                                    userID: userID)
        
        self.isLoading = true
        self.objectWillChange.send()
        
        getFeeds(of: type,
                 request: request) {[weak self] list, error in
            guard let ref = self
            else {
                completion?()
                return
            }
            
            if let error = error {
                ref.error = error
                ref.didEnd = true
            }
            else {
                if shouldRefresh {
                    ref.feeds.removeAll()
                    ref.startAutoRefresh()
                }
                
                if list.isEmpty {
                    ref.didEnd = true
                }
                else {
                    ref.feeds.append(contentsOf: list)
                    ref.pageStart = ref.feeds.count
                    
                    if list.count < ref.pageSize {
                        ref.didEnd = true
                    }
                }
            }
            
            ref.isLoading = false
            ref.objectWillChange.send()
            completion?()
        }
    }
    
    func asyncRefreshFeeds() async {
        await withCheckedContinuation({[weak self] continuation in
            self?.fetchFeeds(shouldRefresh: true, completion: {
                continuation.resume()
            })
        })
    }
    
    
    func segmentTitle() -> String {
        switch category {
        case .generic:
            return NSLocalizedString("feed.list.picker.generic", comment: "")
        case .exclusive:
            return NSLocalizedString("feed.list.picker.exclusive", comment: "")
        }
    }
    
    func showNewPosts() {
        let currentSet = Set(feeds)
        let newPostSet = Set(newFeeds)
        
        let common = newPostSet.intersection(currentSet)
        if !common.isEmpty { //In case common feeds exist, don't drop them
            let unCommon = currentSet.subtracting(newPostSet)
            
            var feeds = newFeeds
            feeds.append(contentsOf: Array(unCommon))
            feeds.sort { lhs, rhs in
//                guard let lhsDate = lhs.feed.createdAt.toDate(),
//                      let rhsDate = rhs.feed.createdAt.toDate()
//                else { return true }
                
//                return lhsDate > rhsDate
                return lhs.feed.id > rhs.feed.id
            }
            self.feeds = feeds
        }
        else { //No duplicate feeds available, so dump the old list & allow to pull more feeds
            self.feeds = newFeeds
            self.didEnd = false
        }
        self.newFeeds.removeAll()
        self.pageStart = feeds.count
                
        self.newPostAvailable = false
    }
    
    func delete(at offsets: IndexSet) {
        feeds.remove(atOffsets: offsets)
    }
}

private extension FeedListViewModel {
    func handleListUpdate(type: FeedListUpdateType) {
        switch type {
        case .delete(let id):
            if let index = feeds.firstIndex(where: { $0.id == id }) {
                var feedList = feeds
                feedList.remove(at: index)
                
                self.feeds = feedList
                self.pageStart = feeds.count
            }
            
            if let index = newFeeds.firstIndex(where: { $0.id == id }) {
                newFeeds.remove(at: index)
                
                self.newPostAvailable = !newFeeds.isEmpty
            }
            
            self.objectWillChange.send()
            if feeds.isEmpty, didEnd == true {
                self.fetchFeeds(shouldRefresh: true)
            }
            
        case .reported(let userID):
            var feedList = feeds
            feedList.removeAll(where: { $0.celebID == userID })
            
            self.feeds = feedList
            self.pageStart = feedList.count
            
            var newPosts = newFeeds
            newPosts.removeAll(where: { $0.celebID == userID })
            
            self.newFeeds = newPosts
            self.newPostAvailable = !newPosts.isEmpty
            
            self.objectWillChange.send()
            
            if feeds.isEmpty, didEnd == true {
                self.fetchFeeds(shouldRefresh: true)
            }
        }
    }
    
    func handleUpdate(type: AppUpdateType) {
        switch type {
        case .celebBlocked(let celebID):
            var feedList = feeds
            feedList.removeAll(where: { $0.celebID == celebID })
                        
            var newPosts = newFeeds
            newPosts.removeAll(where: { $0.celebID == celebID })

            self.feeds = feedList
            self.pageStart = feedList.count
            self.newFeeds = newPosts
            self.newPostAvailable = !newPosts.isEmpty
            
            self.objectWillChange.send()
            break
            
        case .celebUnblocked(_):
            self.feeds.removeAll()
            self.newFeeds.removeAll()
            self.pageStart = 0
            self.newPostAvailable = false
            self.didEnd = false
            
            self.objectWillChange.send()
        }
    }
}

private extension FeedListViewModel {
    func getFeeds(of type:SGFeedType,
                  request: SGFeedRequest,
                  queue: DispatchQueue = .main,
                  completion: @escaping ([SGFeedViewModel], SGAPIError?)->()) {
        
        SGFeedService.getFeeds(of: type,
                               request: request)
        .receive(on: queue)
        .sink { result in
            switch result {
            case .finished: break
            case .failure(let error):
                completion([], error)
            }
        } receiveValue: {[weak self] response in
            guard let _ = self else { return }
            
            let posts = response.result.posts.map({ SGFeedViewModel(with: $0) })
                        
            posts.forEach { post in
                
                if (post.feed.celeb?.id == SGAppSession.shared.user.value?.id) {
                    post.shouldSubscribe = false //It's of current user
                }
                else {
                    post.shouldSubscribe =  post.feed.isExclusive && (post.feed.celeb?.isCelebSub == false) //Require subscription
                }
                
//                post.shouldSubscribe = (ref.category == .exclusive) && (post.feed.celeb?.id != SGAppSession.shared.user.value?.id)
            }
            
            self?.updateStatus(of: posts,
                             with: SGAppSession.shared.subscriptions.value)
            
            completion(posts, nil)
        }
        .store(in: &cancellables)
    }
    
    func checkForNewPosts() {
        let request = SGFeedRequest(pageToken: nil,
                                    pageStart: 0,
                                    limit: pageSize,
                                    filters: nil,
//                                    category: category,
                                    userID: userID)
        
        getFeeds(of: type,
                 request: request,
                 queue: autoRefreshQueue ?? .main) {[weak self] list, error in
            guard let ref = self
            else { return }
            
            guard error == nil
            else { return }
            
            let newFeeds = Set(list)
            let currentFeeds = Set(ref.feeds)
            
            let diff = newFeeds.subtracting(currentFeeds)
            if !diff.isEmpty { //New posts available, ignoring the cached records
                
                self?.newFeeds = list //Include both new feeds & cached feeds(with updated content)
                
                DispatchQueue.main.async {
                    withAnimation {
                        self?.newPostAvailable = true
                    }
             
                }
            }
            else {
                DispatchQueue.main.async {
                    withAnimation {
                        self?.newPostAvailable = false
                    }
                }
            }
        }
    }
    
    func startAutoRefresh() {
        guard shouldAutoRefresh
        else { return }
        
        if autoRefreshTimer != nil {
            autoRefreshTimer?.resume()
        }
        else {
            let queue = DispatchQueue(label: (Bundle.main.bundleIdentifier) ?? "com" + ".feeds.timer" )
            autoRefreshTimer = DispatchSource.makeTimerSource(queue: queue)
            autoRefreshTimer?.schedule(deadline: .now() + .seconds(refreshInterval),
                                       repeating: .seconds(refreshInterval))
            autoRefreshTimer?.setEventHandler(handler: {[weak self] in
//                print("Feeds auto refresh triggered")
                self?.checkForNewPosts()
            })
            
            autoRefreshTimer?.resume()
            autoRefreshQueue = queue
        }
    }
    
    func pauseAutoRefresh() {
        autoRefreshTimer?.suspend()
    }
    
    func stopAutoRefresh() {
        autoRefreshTimer?.cancel()
        autoRefreshTimer = nil
    }
}

private extension FeedListViewModel {
    func updateStatus(of feeds:[SGFeedViewModel], with subscriptions:[SubscriptionItem]) {
        guard !feeds.isEmpty, !subscriptions.isEmpty
        else { return }
        
        
        let isAppUnlocked = (subscriptions.first(where: { $0.type == .appUnlock }) != nil)
        
        if isAppUnlocked {
            for feed in feeds {
                feed.shouldSubscribe = false
            }
            return
        }
        else { //Update for individual celebrity subscription
            for subscription in subscriptions {
                switch subscription.type {
                case .celebrity:
                    
                    guard let celebId = subscription.celeb?.id
                    else { continue }
                    
                    let feeds = feeds.filter({ $0.celebID == celebId })
                    for feed in feeds {
                        feed.shouldSubscribe = false
                    }
                default: break
                }
            }
        }
    }
}
