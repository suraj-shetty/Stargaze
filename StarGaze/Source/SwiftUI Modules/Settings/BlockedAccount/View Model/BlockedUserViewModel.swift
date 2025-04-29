//
//  BlockedUserViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 08/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class BlockedUserViewModel: ObservableObject, Identifiable {
    let id: Int
    let name: String
    let picture: URL?
    let followersCount: UInt64
        
    @Published var loading: Bool = false
    @Published var confirmBlock: Bool = false
    @Published var error: SGAPIError? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach({ $0.cancel() })
    }
    
    init(user: BlockedUser) {
        self.id = user.id
        self.name = user.name
        self.picture = URL(string: user.picture)
        self.followersCount = user.followersCount
    }
    
    func block() {
        loading = true
        SGUserService.unblock(userID: "\(id)")
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    self?.loading = false
                    self?.error = error
                }
            } receiveValue: {[weak self] didUnblock in
                guard let ref = self
                else { return }
                if didUnblock {
                    let info = [AppUpdateNotificationKey.updateType: AppUpdateType.celebUnblocked(ref.id)]
                    NotificationCenter.default.post(name: .celebrityUnblocked,
                                                    object: nil,
                                                    userInfo: info)
                }
                else {
                    self?.error = SGAPIError.custom("Failed to unblock the user. Try again later.")
                }
            }
            .store(in: &cancellables)
    }
}
