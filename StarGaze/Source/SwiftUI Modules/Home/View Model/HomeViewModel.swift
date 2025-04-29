//
//  HomeViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var tabIndex: Int = 0
    @Published var pickedTab: TabType = .feeds
    
    @Published var feedsVM = FeedsViewModel()
    @Published var eventsVM = EventListViewModel()
    @Published var celebVM = CelebrityHomeViewModel()
    
    @Published var rewards: DailyRewardListViewModel? = nil
    private var rewardObserver = Set<AnyCancellable>()
    
    func fetchDailyRewards() {
        SGWalletService.getDailyRewards()
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: {[weak self] rewards in
                if !rewards.isEmpty {
                    self?.rewards = DailyRewardListViewModel(rewards: rewards)
                }
            })
            .store(in: &rewardObserver)
    }
}

class FeedsViewModel: ObservableObject {
    @Published var feeds: FeedListViewModel!
    @Published var filteredFeeds: FeedListViewModel?
    
    @Published var filterList = FilterListViewModel()
    @Published var showFilter: Bool = false        
        
    @Published var viewState: ViewState = ViewState()
    
    @Published var feed:SGFeedViewModel? = nil
    
    private var cancellables = [AnyCancellable]()
    private var feedFetchPublisher: AnyCancellable? = nil
    private var subscriptionUpdateCancellable: AnyCancellable?
    
    init() {
        let genericViewModel = FeedListViewModel(for: nil,
                                                 type: .allFeedsList,
                                                 category: .generic,
                                                 autoRefresh: true)
        
//        let exclusiveViewModel = FeedListViewModel(for: nil,
//                                                   type: .allFeedsList,
//                                                   category: .exclusive)
        
//        let segments = FeedSegmentsViewModel(segments: [genericViewModel])
        
        self.feeds = genericViewModel
        
        let listPublisher = genericViewModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        
        cancellables.append(listPublisher)
        
        
        self.subscriptionUpdateCancellable = SGAppSession.shared.subscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] subscriptions in
                guard let ref = self, let feed = ref.feed
                else { return }
                
                ref.updateStatus(of: feed, with: subscriptions)
            })
    }
    
    deinit {
        self.cancellables.forEach{(
            $0.cancel()
        )}
        self.cancellables.removeAll()
        self.subscriptionUpdateCancellable?.cancel()
    }
    
    func getFeed(of id: Int) {
        if let cancellable = feedFetchPublisher {
            cancellable.cancel()
        }
        
        if let feed = feeds.feeds.first(where: { $0.id == id }) {
            self.feed = feed
            return
        }
        
        SGAlertUtility.showHUD()
        self.feedFetchPublisher = SGFeedService.getFeed(id: id)
            .sink { completion in
                SGAlertUtility.hidHUD()
                switch completion {
                case .failure(let error):
                    SGAlertUtility.showErrorAlert(message: error.localizedDescription)
                    
                case .finished: break
                }
            } receiveValue: {[weak self] post in
                let feedVM = SGFeedViewModel(with: post)
                
                if (post.celeb?.id == SGAppSession.shared.user.value?.id) {
                    feedVM.shouldSubscribe = false //It's of current user
                }
                else {
                    feedVM.shouldSubscribe =  post.isExclusive && (post.celeb?.isCelebSub == false) //Require subscription
                }
                
                let subscriptions = SGAppSession.shared.subscriptions.value
                if feedVM.shouldSubscribe,
                   !subscriptions.isEmpty {
                    self?.updateStatus(of: feedVM, with: subscriptions)
                }                
                self?.feed = feedVM
            }        
    }
}

class CelebrityHomeViewModel: ObservableObject {
    @Published var listViewModel = SGCelebListViewModel()
    @Published var trendingViewModel = SGTopCelebListViewModel()
    
    @Published var pickedCelebrity: SGCelebrityViewModel?
    
    private var cancellables = [AnyCancellable]()
    private var fetchCelebSubscriber: AnyCancellable?
    
    init() {
        let listPubLisher = listViewModel.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
        
        let trendingPublisher = trendingViewModel.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
        
        cancellables.append(listPubLisher)
        cancellables.append(trendingPublisher)
    }
    
    deinit {
        self.cancellables.forEach{(
            $0.cancel()
        )}
        self.cancellables.removeAll()
        self.fetchCelebSubscriber?.cancel()
    }
    
    func fetchCelebrity(with id:Int) {
        fetchCelebSubscriber?.cancel()
        
        let record = listViewModel.celebrities
            .first(where: { $0.id == id })
        ?? trendingViewModel.celebrities
            .first(where: { $0.id == id })
        
        if let celebrityVM = record {
            self.pickedCelebrity = celebrityVM
            return
        }
        
        SGAlertUtility.showHUD()
        self.fetchCelebSubscriber = SGCelebrityService.fetchDetail(for: id)
            .sink { completion in
                SGAlertUtility.hidHUD()
                switch completion {
                case .failure(let error):
                    SGAlertUtility.showErrorAlert(message: error.localizedDescription)
                    
                case .finished: break
                }
            } receiveValue: {[weak self] celebrity in
                let viewModel = SGCelebrityViewModel(celebrity: celebrity)
                viewModel.shouldRefresh = false
                self?.pickedCelebrity = viewModel
            }
    }
}


private extension FeedsViewModel {
    func updateStatus(of feed:SGFeedViewModel, with subscriptions:[SubscriptionItem]) {
        guard !subscriptions.isEmpty
        else { return }
        
        
        let isAppUnlocked = (subscriptions.first(where: { $0.type == .appUnlock }) != nil)
        
        if isAppUnlocked {
            feed.shouldSubscribe = false
            return
        }
        else { //Update for individual celebrity subscription
            for subscription in subscriptions {
                switch subscription.type {
                case .celebrity:
                    guard let celebId = subscription.celeb?.id, feed.celebID == celebId
                    else { continue }
                    
                    feed.shouldSubscribe = false
                default: break
                }
            }
        }
    }
}
