//
//  FilterViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 23/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class FilterListViewModel: ObservableObject {
    @Published private(set) var datasource = [SGFilter]()
    @Published var pickedFilters = [SGFilter]()
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchFilters() {
        SGFeedService.getFilters()
            .sink { result in
                switch result {
                case .failure(let error):
                    debugPrint("Failed to fetch filters \(error)")
                    break
                    
                case .finished: break
                }
                
            } receiveValue: {[weak self] filters in
                guard let ref = self else { return }
                ref.datasource.removeAll()
                
                let activeFilters = filters.filter({ $0.status == .active }).sorted { lhs, rhs in
                    return lhs.id < rhs.id
                }
                
                let parentFilters = activeFilters.filter({ $0.parentID == nil })
                
                for index in 0..<parentFilters.count {
                    var filter = parentFilters[index]
                    let subFilters = activeFilters.filter({ $0.parentID == filter.id })
                    
                    filter.subFilters = subFilters
                    ref.datasource.append(filter)
                }
            }
            .store(in: &cancellables)
    }
}
