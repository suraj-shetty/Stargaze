//
//  MyEventListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 27/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

@MainActor
class MyEventListViewModel: ObservableObject {
    
    private(set) var loading: Bool = false
    private(set) var error: SGAPIError? = nil
    private(set) var didEnd: Bool = false
    private(set) var events: [SGEventViewModel] = []
        
    private let apiService = MyEventServices()
    private let pageSize: Int = 10
    
    func getEvents(refresh: Bool) async {
        if !refresh { //Not a refresh and no more records available
            if didEnd || loading {
                return
            }
        }
        
        if refresh {
            self.didEnd = false
        }
        
        self.loading = true
        self.objectWillChange.send()

        let start = refresh ? 0 : events.count
        let request = MyEventRequest(isCeleb: true,
                                     start: start) //This ViewModel is used for celebrity's My Event History. So isCeleb flag is always true
        
        let result = await apiService.getEvents(for: request)
        switch result {
        case .success(let success):
            let list = success.result.map({ SGEventViewModel(event: $0) })
            
            if refresh {
                self.events = list
            }
            else {
                self.events.append(contentsOf: list)
            }
            
            if list.count < self.pageSize {
                self.didEnd = true
            }
            
        case .failure(let failure):
            self.error = failure
            self.didEnd = true
        }
        
        self.loading = false
        self.objectWillChange.send()
    }
}
