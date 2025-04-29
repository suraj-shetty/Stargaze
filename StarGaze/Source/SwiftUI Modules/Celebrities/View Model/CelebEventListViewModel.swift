//
//  CelebEventListViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 04/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class CelebEventListViewModel: ObservableObject {
    private var celebrityID:Int!
    private var type:EventType!
    
    @Published private(set) var events: [SGEventViewModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var didEnd: Bool = false
    @Published private(set) var error: SGAPIError?
    
    private(set) var scrollTracker:ListScrollTracker!
    
    private var pageIndex:Int = 0
    private let pageSize = 20
    private var cancellables = Set<AnyCancellable>()
    
    init(with celebrity: SGCelebrity, type: EventType) {
        self.celebrityID = celebrity.id
        self.type = type
        self.scrollTracker = ListScrollTracker()
    }
    
    func segmentTitle() -> String {
        switch type {
        case .videoCall:
            return NSLocalizedString("event.list.picker.videoCall", comment: "")
            
        case .show:
            return NSLocalizedString("event.list.picker.shows", comment: "")
            
        case .none:
            return ""
        }
    }
    
    func getEvents(refresh: Bool) {
        switch type {
        case .videoCall: getVideoCalls(refresh: refresh)
        case .show: getShows(refresh: refresh)
        case .none: return
        }
    }
    
    private func getVideoCalls(refresh: Bool) {
        if refresh == false {
            if didEnd == true { //No more records available, so return
                return
            }
            else if isLoading { //Already a request is in progress, so ignore
                return
            }
        }
        else {
            didEnd = false //Resetting the end of page check, since a refresh is called
            for cancellable in cancellables {
                cancellable.cancel() // stopping previous API calls
            }
        }
        
        let pageStart = refresh ? 0 : events.count
        let request = CelebEventRequest(celebID: celebrityID,
                                        startIndex: pageStart,
                                        count: pageSize)

        isLoading = true
        SGCelebrityService.fetchVideoCalls(for: request)
            .sink {[weak self] result in
                
                switch result {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .cancelled : break
                    default: self?.error = error
                    }
                }
                self?.isLoading = false
            } receiveValue: {[weak self] result in
                guard let ref = self else { return }
                
                let viewModels = result.result.map({ SGEventViewModel(event: $0) })
                
                ref.pageIndex = pageStart + viewModels.count
                if viewModels.count < ref.pageSize {
                    ref.didEnd = true
                }
                
                if refresh {
                    ref.events = viewModels
                }
                else {
                    ref.events.append(contentsOf: viewModels)
                }
                ref.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func getShows(refresh: Bool) {
        if refresh == false {
            if didEnd == true { //No more records available, so return
                return
            }
            else if isLoading { //Already a request is in progress, so ignore
                return
            }
        }
        else {
            didEnd = false //Resetting the end of page check, since a refresh is called
            for cancellable in cancellables {
                cancellable.cancel() // stopping previous API calls
            }
        }
        
        let pageStart = refresh ? 0 : events.count
        let request = CelebEventRequest(celebID: celebrityID,
                                        startIndex: pageStart,
                                        count: pageSize)

        isLoading = true
        SGCelebrityService.fetchShows(for: request)
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .cancelled : break
                    default: self?.error = error
                    }
                }
                self?.isLoading = false
            } receiveValue: {[weak self] result in
                guard let ref = self else { return }
                
                let viewModels = result.result.map({ SGEventViewModel(event: $0) })
                
                ref.pageIndex = pageStart + viewModels.count
                if viewModels.count < ref.pageSize {
                    ref.didEnd = true
                }
                
                if refresh {
                    ref.events = viewModels
                }
                else {
                    ref.events.append(contentsOf: viewModels)
                }
                ref.isLoading = false
            }
            .store(in: &cancellables)
    }
}
