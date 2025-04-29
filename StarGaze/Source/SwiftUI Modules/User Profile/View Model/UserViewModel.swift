//
//  UserViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    private var user: UserDetail? {
        get {
            return SGAppSession.shared.user.value
        }
    }
    
    private var wallet: Wallet? {
        get {
            return SGAppSession.shared.wallet.value
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    @Published var error: SGAPIError?
    @Published var isLoading: Bool = false
    
    init() {
        SGAppSession.shared
            .user
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.objectWillChange.send() //Signaling changes on receiving new user detail object
            })
            .store(in: &cancellables)
        
        SGAppSession.shared
            .wallet
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.objectWillChange.send() //Signaling changes on receiving new wallet details object
            })
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach({ $0.cancel() })
    }
        
    var name: String {
        get { return user?.name ?? "" }
    }
    
    var phoneNumberText: String {
        get {
            guard let user = user else {
                return ""
            }

            if Int(user.dialCode ?? "0") == 0 {
                return ""
            }
            
            return "+\(user.dialCode!) \(user.mobileNumber)"
        }
    }
    
    var emailAddress: String {
        get {
            guard let user = user else {
                return ""
            }

            return user.email ?? ""
        }
    }
    
    var profileURL: URL? {
        get { return URL(string: user?.picture ?? "") }
    }
    
    var role: UserRole {
        get { return user?.role ?? .user }
    }
    
    var followingsCount: Int {
        get {
            return user?.totalFollowings ?? 0
        }
    }
    
    var eventCountText: String {
        get {
            let count = user?.totalEvents ?? 0
            return countText(with: count, localizedKey: "events.count")
        }
    }
    
    var followersCountText: String {
        get {
            let count = user?.totalFollowers ?? 0
            return countText(with: count, localizedKey: "followers.count")
        }
    }
    
    var subscribersCountText: String {
        get {
            let count = user?.totalSubscribers ?? 0
            return countText(with: count, localizedKey: "subscribers.count")
        }
    }
    
    var goldCoinsCount: Int {
        get { return wallet?.goldCoins ?? 0 }
    }
    
    var silverCoinsCount: Int {
        get { return wallet?.silverCoins ?? 0 }
    }
    
    var bioText: String {
        get { return user?.bio ?? "" }
    }
    
    var hashtags: [String] {
        get {
            guard let categories = user?.celebrityDetail?.categories,
                  categories.isEmpty == false
            else {
                return []
            }
            
            let hashtags = categories.map({ "#" + $0.name })
            return hashtags
        }
    }
    
    var isCelebrity: Bool {
        get {
            let role = user?.role ?? .user
            return (role == .celebrity)
        }
    }
    
    var isSocialAccount: Bool {
        get {
            if let _ = user?.socialType {
                return true
            }
            return false
        }
    }
    
    private func countText(with count:Int, localizedKey: String) -> String {
        let countText = localizedKey.formattedString(value: count)
        return countText
    }
}

extension UserViewModel {
    func fetchUpdates() {
        
        let profileSubject = SGUserService.getProfile()
        let walletSubject = SGWalletService.getWalletDetails()
        
        let combined = Publishers.Zip(profileSubject,
                                      walletSubject)
        
        isLoading = true
        combined.sink {[weak self] result in
            self?.isLoading = false
            
            switch result {
            case .finished: break
            case .failure(let failure):
                self?.error = failure.id
                self?.isLoading = false
            }
        } receiveValue: { detail, wallet in
            let session = SGAppSession.shared
            session.user.send(detail)
            session.wallet.send(wallet)
            
            SGUserDefaultStorage.saveUserData(user: detail)
            
            self.isLoading = false
        }
        .store(in: &cancellables)

        Task(priority: .background) {
            let result = await SubscriptionServices.shared.getList()
            switch result {
            case .success(let success):
                let subscriptions = success.result
                SGAppSession.shared.subscriptions.send(subscriptions)
                
            case .failure(let failure):
                self.error = failure
            }
        }
    }
}
