//
//  BlockedListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 08/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
class BlockedListViewModel: ObservableObject {
    var list: [BlockedUserViewModel] = []
    var loading: Bool = false
    var error: SGAPIError? = nil
    var didEnd: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach({ $0.cancel() })
    }
    
    init() {
        NotificationCenter.default
            .publisher(for: .celebrityUnblocked)
            .sink {[weak self] notification in
                guard let ref = self
                else { return }
                
                guard let type = notification.userInfo?[AppUpdateNotificationKey.updateType] as? AppUpdateType
                else { return }
                
                switch type {
                case .celebBlocked(_):
                    break
                case .celebUnblocked(let int):
                    if let index = ref.list.firstIndex(where: { $0.id == int }) {
                        ref.list.remove(at: index)
                        ref.objectWillChange.send()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func fetch() {
        if loading || didEnd {
            return
        }
        
        let request = BlockedListRequest(start: list.count,
                                         limit: 10)
        
        loading = true
        SGUserService.shared.getBlockedList(request: request)
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    self?.error = error
                    self?.loading = false
                    self?.didEnd = true
                    self?.objectWillChange.send()
                }
            } receiveValue: {[weak self] list in
                self?.loading = false
                self?.didEnd = (list.count < 10)
                
                if !list.isEmpty {
                    let users = list.map({ BlockedUserViewModel(user: $0) })
                    self?.list.append(contentsOf: users)
                }
                
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
