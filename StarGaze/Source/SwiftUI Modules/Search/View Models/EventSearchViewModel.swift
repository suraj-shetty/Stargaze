//
//  EventSearchViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 28/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class EventSearchViewModel: ObservableObject {
    private let pageSize: Int = 10
    private var pageStart: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    
    var events = [SGEventViewModel]()
    var didEnd: Bool = false
    var isLoading: Bool = false
    var error: SGAPIError? = nil
    var lastSearchText: String = ""
    
    let searchSubject = PassthroughSubject<String, Never>()
        
    init() {
        searchCancellable = searchSubject
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .removeDuplicates()
            .map({[weak self] (string) -> String? in
                if string.count < 3 {
                    self?.events.removeAll()
                    self?.isLoading = true
                    self?.didEnd = false
                    self?.objectWillChange.send()
                    return nil
                }
                
                return string
            })
            .compactMap({ $0 })
            .sink {[weak self] search in
                self?.load(with: search)
            }
    }
    
    
    private func load(with text: String, refresh: Bool = false) {
        
        let shouldClear: Bool = (text != lastSearchText) || refresh
        
        if shouldClear {
            self.events.removeAll()
            self.didEnd = false
            self.isLoading = false
            
            for cancellable in cancellables {
                cancellable.cancel() //Cancel all previous requests
            }
            cancellables.removeAll()
        }
        
        self.lastSearchText = text
        
        let index = events.count
        let request = SearchRequest(search: text,
                                    startIndex: index,
                                    pageSize: pageSize)
        fetch(with: request)
    }
    
    func loadNext() {
        if isLoading || didEnd { //If pending request or page ended
            return
        }
        
        let index = events.count
        let request = SearchRequest(search: lastSearchText,
                                    startIndex: index,
                                    pageSize: pageSize)
        fetch(with: request)
        
    }
}

private extension EventSearchViewModel {
    func fetch(with request: SearchRequest) {
        isLoading = true
        self.objectWillChange.send()
        
        SGEventService.searchEvents(with: request)
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .cancelled : break
                    default: self?.error = error
                    }
                    self?.didEnd = true
                    self?.isLoading = false
                    self?.objectWillChange.send()
                }
            } receiveValue: {[weak self] events in
                guard let ref = self
                else { return }
                
                let result = events.result
                let viewModels = result.map({ SGEventViewModel(event: $0) })
                
                ref.isLoading = false
                ref.events.append(contentsOf: viewModels)
                
                if result.count < ref.pageSize {
                    ref.didEnd = true
                }
                                
                ref.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
