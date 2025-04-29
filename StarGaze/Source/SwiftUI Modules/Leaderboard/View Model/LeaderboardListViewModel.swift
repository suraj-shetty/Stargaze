//
//  LeaderboardListViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class LeaderboardListViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var error: SGAPIError?
        
    private let pageSize: Int = 20
    private var cancellables = Set<AnyCancellable>()
    
    var list: [LeaderboardViewModel] = []
    var didEnd:Bool = false
    
    let type: LeaderboardOption!
    
    init(type: LeaderboardOption) {
        self.type = type
    }
        
    func fetchList(refresh: Bool) {
        if refresh == false {
            if isLoading || didEnd {
                return
            }
        }
        else {
            didEnd = false //Resetting the end of page check, since a refresh is called
            
            for cancellable in cancellables {
                cancellable.cancel() // stopping previous API calls
            }
        }
        
        let index = refresh ? 0 : list.count
        let request = LeaderboardCategoryRequest(type: type,
                                                 start: index,
                                                 pageSize: pageSize)
        
        isLoading = true
        LeaderboardService.getList(for: request)
            .sink {[weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
                
                self?.isLoading = false
            } receiveValue: {[weak self] output in
                guard let ref = self
                else {
                    return
                }
                
                let categories = output.result
                    .map({ LeaderboardViewModel(category: $0, filter: ref.type) })
                
                if refresh {
                    self?.list.removeAll()
                }
                
                self?.list.append(contentsOf: categories)
                
                if categories.count < request.pageSize {
                    self?.didEnd = true
                }
            }
            .store(in: &cancellables)
    }
}
