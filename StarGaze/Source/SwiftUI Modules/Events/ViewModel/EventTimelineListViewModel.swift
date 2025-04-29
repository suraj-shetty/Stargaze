//
//  EventTimelineListViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 25/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Combine
import SwiftDate
class EventTimelineListViewModel: ObservableObject {
//    private(set)
    var timeline = [EventTimelineViewModel]()
    private(set) var isLoading: Bool = false
    private(set) var didEnd: Bool = false
    private(set) var error: SGAPIError? = nil
    
    private let isCelebrity: Bool
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.isCelebrity = (SGAppSession.shared.user.value?.role == .celebrity)
    }
    
    
    func fetch(refresh: Bool) {
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
        
        let start = refresh ? 0 : timeline.count
        let request = EventHistoryRequest(isActive: false,
                                          didWin: false,
                                          getTimeLine: true,
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
                    ref.timeline.removeAll()
                }
                
                var prevDate: String? = ref.timeline.last?.fullDateText()
                let currentYear = Date().year
                for event in events {
                    guard !ref.timeline.contains(where: { $0.id == event.id })
                    else { continue }
                    
                    let date = event.startDate
                    let day = date.day
                    let month = date.monthName(.short)
                    let year = date.year
                    let time = date.formatted(date: .omitted,
                                              time: .shortened)
                    
                    var timelineEntry = EventTimelineViewModel(id: event.id,
                                                               title: event.title,
                                                               celebName: event.celeb?.name ?? "",
                                                               day: "\(day)",
                                                               month: month.capitalized,
                                                               year: (year != currentYear) ? "\(year)" : "",
                                                               time: time,
                                                               isFirst: (prevDate == nil),
                                                               hasPrevious: false)
                    
                    if prevDate != nil, prevDate == timelineEntry.fullDateText() {
                        timelineEntry.hasPrevious = true
                    }
                    else {
                        prevDate = timelineEntry.fullDateText()
                        timelineEntry.hasPrevious = false
                    }
                    
                    ref.timeline.append(timelineEntry)
                }
                
                ref.didEnd = events.count < 10 //Replace it with actual pageSize, if changed. By default, on backend, its 10
                ref.isLoading = false
                
                ref.objectWillChange.send()
            }
            .store(in: &cancellables)

        
    }
}

