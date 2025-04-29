//
//  LeaderboardViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class LeaderboardViewModel: ObservableObject, Identifiable {
    let title: String!
    let id: Int!
    
    private let filter: LeaderboardOption!
    
    var users = [LeaderboardUser]()
    var didEnd: Bool = false
    
    private let pageSize: Int = 20
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var error: SGAPIError?
    
    init(category: LeaderboardCategory, filter: LeaderboardOption) {
        self.id     = category.id
        self.title  = category.name
        self.users  = category.users
        self.filter = filter
    }
    
    func getUsers(refresh: Bool) {
        if refresh == false {
            if isLoading || didEnd {
                return
            }
        }
        else {
            didEnd = false
            
            for cancellable in cancellables {
                cancellable.cancel() // stopping previous API calls
            }
        }
        
        let start = refresh ? 0 : users.count
        let request = LeaderboardDetailRequest(id: id,
                                               filter: filter,
                                               start: start,
                                               pageSize: pageSize)
        isLoading = true
        LeaderboardService.getDetails(for: request)
            .sink {[weak self] completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    self?.error = error
                }
                
                self?.isLoading = false
                
            } receiveValue: {[weak self] output in
                let users = output.result.users
                self?.users = users
                
                //TODO: - Right now pagination is not working on the API side.
//                if refresh {
//                    self?.users.removeAll()
//                }
//
//                self?.list.append(contentsOf: categories)
                
                if users.count < request.pageSize {
                    self?.didEnd = true
                }
            }
            .store(in: &cancellables)
    }
}

extension LeaderboardViewModel: Hashable {
    static func == (lhs: LeaderboardViewModel, rhs: LeaderboardViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
