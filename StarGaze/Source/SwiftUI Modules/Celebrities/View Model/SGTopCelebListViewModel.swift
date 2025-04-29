//
//  SGTopCelebListViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class SGTopCelebListViewModel: ObservableObject {
    @Published private(set) var celebrities = [SGCelebrityViewModel]()
    @Published private(set) var isLoading:Bool = false
    @Published private(set) var didEnd:Bool = false
    @Published private(set) var error:SGAPIError?
    
    private var pageIndex:Int = 0
    private let pageSize = 20
    private var cancellables = Set<AnyCancellable>()
    private var notificationSubscribers = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default
            .publisher(for: .celebrityBlocked)
            .sink {[weak self] notification in
                let userInfo = notification.userInfo
                if let type = userInfo?[AppUpdateNotificationKey.updateType] as? AppUpdateType {
                    self?.handleUpdate(type: type)
                }
            }
            .store(in: &notificationSubscribers)
    }
    
    deinit {
        notificationSubscribers.forEach({ $0.cancel() })
        notificationSubscribers.removeAll()
    }
    
    func fetchCelebrities(refresh:Bool) {
        
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
        
        let index = refresh ? 0 : pageIndex
        let request = SGTopCelebRequest(start: index,
                                        pageSize: pageSize)
        
        isLoading = true
        SGCelebrityService.fetchRecommendation(for: request)
            .sink { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .cancelled : break
                    default:
                        self.error = error
                        self.didEnd = true
                    }
                }
                self.isLoading = false
            } receiveValue: { response in
                self.pageIndex = index + response.count
                
                let celebs = response.map({ SGCelebrityViewModel(celebrity: $0) })
                
                if celebs.count < self.pageSize {
                    self.didEnd = true
//                    self.pageId = nil
                }
                else {
//                    self.pageId = response.nextPageID
                    self.didEnd = false
                }
                
                if refresh {
                    self.celebrities = celebs
                }
                else {
                    self.celebrities.append(contentsOf: celebs)
                }
                
                self.isLoading = false
            }
            .store(in: &cancellables)
        
    }
    
    private func handleUpdate(type: AppUpdateType) {
        switch type {
        case .celebBlocked(let int):
            self.celebrities.removeAll(where: { $0.celebrity.id == int })
            self.pageIndex = self.celebrities.count
            
        case .celebUnblocked(_): //To refresh
            self.celebrities.removeAll()
            self.pageIndex = 0
            self.didEnd = false
        }
    }
}
