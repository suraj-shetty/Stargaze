//
//  VideoCallListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 22/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftDate

struct EventHistoryViewModel: Identifiable {
    let id: Int
    let title: String
    let celebName: String
    let dateText: String
    let imageURL: URL?
}

class EventHistoryListViewModel: ObservableObject {
    let type: EventHistoryListType
    let eventType: EventType
    
    private(set) var list: [EventHistoryViewModel]
    private(set) var isLoading: Bool = false
    private(set) var didEnd: Bool = false
    private(set) var pageSize: Int = 10
    private(set) var error: SGAPIError? = nil
    
    private let isCelebrity: Bool
    private var cancellables = Set<AnyCancellable>()
    
    init(type: EventHistoryListType, eventType:EventType) {
        self.type = type
        self.eventType = eventType
        self.list = []
        
        self.isCelebrity = (SGAppSession.shared.user.value?.role == .celebrity)
    }
    
    func fetch(refresh: Bool = false) {
        if !refresh, didEnd { //Not a refresh and no more records available
            return
        }
        
        if refresh {
            didEnd = false
            cancellables.forEach({ $0.cancel() }) //Cancelling all previous request
            cancellables.removeAll()
        }
        
        
        isLoading = true
        self.objectWillChange.send()
        
        let start = refresh ? 0 : list.count
        let request = EventHistoryRequest(isActive: type == .active,
                                          didWin: type == .won,
                                          getTimeLine: type == .timeline,
                                          isCeleb: isCelebrity,
                                          start: start)
        
        SGEventService.eventHistory(request: request)
            .sink {[weak self] result in
                switch result {
                case .failure(let error):
                    self?.error = error
                    self?.didEnd = true
                    self?.isLoading = false
                    self?.objectWillChange.send()
                    
                case .finished: break
                }
            } receiveValue: {[weak self] events in
                guard let ref = self
                else { return}
                
                if refresh {
                    ref.list.removeAll()
                }
                
                let viewModels = events.map{
                    return EventHistoryViewModel(id: $0.id,
                                              title: $0.title,
                                              celebName: $0.celeb?.name ?? "",
                                              dateText: $0.displayDate,
                                              imageURL: URL(string: $0.mediaPath))
                }
                
                ref.list.append(contentsOf: viewModels)
                ref.didEnd = events.count < ref.pageSize
                ref.isLoading = false
                
                ref.objectWillChange.send()
            }
            .store(in: &cancellables)

        
    }
    
    
//    @MainActor
//    private func update(with list:[VideoCallListViewModel], error: SGAPIError?) {
//
//    }
}

class EventHistoryGroupViewModel: ObservableObject {
    let group: [EventHistoryListViewModel]
    @Published var index: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(group: [EventHistoryListViewModel]) {
        self.group = group
        
        for list in group {
            list.objectWillChange
                .sink {[weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }
    
    deinit {
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
    
}

extension EventHistoryViewModel {
    static var preview: EventHistoryViewModel {
        return EventHistoryViewModel(id: 0,
                                  title: "Fashion fades, only style remains randomised…",
                                  celebName: "Brad Pitt",
                                  dateText: "Dec 22 at 7:30pm",
                                  imageURL: nil)
    }
}

extension EventHistoryListViewModel {
    var title: String {
        switch self.type {
        case .active: return NSLocalizedString("video-call.history.segment.active-event.title", comment: "")
            
        case .won: return NSLocalizedString("video-call.history.segment.events.won.title", comment: "")
            
        case .timeline: return NSLocalizedString("event-history.timeline.title", comment: "")
            
        case .all: return NSLocalizedString("video-call.history.segment.events.title", comment: "")
        }
    }
}
