//
//  NotificationListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 20/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

@MainActor
class NotificationListViewModel: ObservableObject {
    var notifications = [NotificationViewModel]()
    var isLoading: Bool = false
    var error: SGAPIError? = nil
    var didEnd: Bool = false
    
    private let apiService = NotificationService()
    
    func fetch(refresh: Bool = false) {
        
        if !refresh, didEnd {
            return
        }
        
        let start = refresh ? 0 : notifications.count
        let request = NotificationListRequest(start: start)
        
        isLoading = true
        self.objectWillChange.send()
        
        Task {
            let result = await apiService.getList(for: request)
            switch result {
            case .success(let success):
                let list = success.result.map({
                    let vm = NotificationViewModel(notification: $0)
                    vm.apiService = self.apiService
                    
                    return vm
                })
                
                if refresh {
                    self.notifications.removeAll()
                }
                
                self.notifications.append(contentsOf: list)
                self.didEnd = list.count < 10
                
                
            case .failure(let failure):
                self.error = failure
                self.didEnd = true
            }
            self.isLoading = false
            self.objectWillChange.send()
        }
    }
}

