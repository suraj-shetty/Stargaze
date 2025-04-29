//
//  FeedSearchViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 27/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class FeedSearchViewModel: ObservableObject {
    private(set) var scrollTracker:ListScrollTracker!
    
    private let pageSize: Int = 10
    private var pageStart: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private var currentItemCancellable: AnyCancellable?
    private var searchCancellable: AnyCancellable?
    private var subscriptionUpdateCancellable: AnyCancellable?
    
    var feeds = [SGFeedViewModel]()
    var didEnd: Bool = false
    var isLoading: Bool = false
    var error: SGAPIError? = nil
    var lastSearchText: String = ""
    
    @Published var playableFeedIndex:Int?
    
    let searchSubject = PassthroughSubject<String, Never>()
    
    
    init() {
        self.scrollTracker = ListScrollTracker()
        
        self.currentItemCancellable = self.scrollTracker
            .centeredElementPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in
                self?.playFeedAtIndex($0)
            }
        
        
        searchCancellable = searchSubject
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .removeDuplicates()
            .map({[weak self] (string) -> String? in
                if string.count < 3 {
                    self?.feeds.removeAll()
                    self?.isLoading = true
                    self?.didEnd = false
                    self?.objectWillChange.send()
                    return nil
                }
                
                return string
            })
            .compactMap({ $0 })
            .sink {[weak self] search in
                print("Text to search \(search)")
                self?.load(with: search)
            }
        
        self.subscriptionUpdateCancellable = SGAppSession.shared.subscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] subscriptions in
                guard let ref = self
                else { return }
                
                ref.updateStatus(of: ref.feeds, with: subscriptions)
                
//                for subscription in subscriptions {
//
//                    let celebId = subscription.celeb?.id ?? 0
//                    let hasSubscription = SGAppSession.shared.hasSubscription(for: celebId)
//
//                    guard let feeds = self?.feeds
//                        .filter({ $0.celebID == celebId }),
//                            !feeds.isEmpty
//                    else { continue }
//
//                    for feed in feeds {
//                        if feed.shouldSubscribe {
//                            feed.shouldSubscribe = !hasSubscription
//                        }
//                    }
//                }
                self?.objectWillChange.send()
            })
    }
    
    deinit {
        /*
            If the timer is suspended, calling cancel without resuming
            triggers a crash. This is documented here
            https://forums.developer.apple.com/thread/15902
            */
                        
        cancellables.forEach{ $0.cancel() }
        cancellables.removeAll()
        
        currentItemCancellable?.cancel()
        currentItemCancellable = nil
        
        searchCancellable?.cancel()
        searchCancellable = nil
        
        subscriptionUpdateCancellable?.cancel()
        subscriptionUpdateCancellable = nil
    }
    
}

extension FeedSearchViewModel {
    private func load(with text: String, refresh: Bool = false) {
        
        let shouldClear: Bool = (text != lastSearchText) || refresh
        
        if shouldClear {
            self.feeds.removeAll()
            self.didEnd = false
            self.isLoading = false
            
            for cancellable in cancellables {
                cancellable.cancel() //Cancel all previous requests
            }
            cancellables.removeAll()
        }
        
        self.lastSearchText = text
        
//        if text.isEmpty {
//            self.didEnd = true
//            self.objectWillChange.send()
//            return
//        }
        
        
        let index = feeds.count
        let request = SearchRequest(search: text,
                                        startIndex: index,
                                        pageSize: pageSize)
        fetchFeeds(for: request)
    }
    
    func loadNext() {
        if isLoading || didEnd { //If pending request or page ended
            return
        }
        
        let index = feeds.count
        let request = SearchRequest(search: lastSearchText,
                                        startIndex: index,
                                        pageSize: pageSize)
        fetchFeeds(for: request)
        
        print("Load next for \(lastSearchText)")
    }
}

private extension FeedSearchViewModel {
    func fetchFeeds(for request: SearchRequest) {
        isLoading = true
        self.objectWillChange.send()
        
        SGFeedService.search(for: request)
            .sink {[weak self] result in
                switch result {
                case .failure(let error):
                    self?.error = error
                    self?.isLoading = false
                    self?.didEnd = true
                    self?.objectWillChange.send()
                    
                case .finished: break
                }
            } receiveValue: {[weak self] response in
                guard let ref = self
                else { return }
                                                         
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
                
                ref.updateStatus(of: posts, with: SGAppSession.shared.subscriptions.value)
                
                ref.feeds.append(contentsOf: posts)
                ref.isLoading = false
                ref.didEnd = (posts.count < ref.pageSize)
                ref.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

extension FeedSearchViewModel {
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
        if let lastIndex = playableFeedIndex {
            let feed = feeds[lastIndex]
            feed.allowPlaying = false
        }
        
        let feed = feeds[index]
        feed.allowPlaying = true
        
        self.playableFeedIndex = index
    }
}

private extension FeedSearchViewModel {
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
