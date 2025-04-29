//
//  SGCelebrityViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import KMBFormatter
import SwiftUI
import Combine
import FirebaseDynamicLinks

class SGCelebrityViewModel: ObservableObject, Identifiable {
    private(set) var celebrity:SGCelebrity
    private(set) var isBlocked: Bool = false
    
    @Published var isFollowed:Bool
    @Published var followersCount:Int
    
    @Published var isLoading: Bool = false
    @Published var shouldRefresh: Bool = true
    
    @Published var error:SGAPIError?
    
    @Published var isSubscribed: Bool = false
    @Published var linkGenerating: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var subscriptionCancellable: AnyCancellable?
    
    var id:Int {
        get { celebrity.id }
    }
    
    var name:String {
        get { celebrity.name }
    }
    
    var bio:String {
        get { celebrity.about ?? "" }
    }
    
    var picURL:URL? {
        get { URL(string: celebrity.picture ?? "") }
    }
        
    var followersCountText:String {
        get {
            let formatText = NSLocalizedString("followers.count", comment: "")
            return String.localizedStringWithFormat(formatText, KMBFormatter.shared.string(fromNumber: Int64(followersCount)))
        }
    }
    
    var isMyProfile: Bool {
        get {
            guard let userID = SGAppSession.shared.user.value?.id
            else {
                return false
            }
            
            return userID == self.id            
        }
    }
    
    init(celebrity:SGCelebrity) {
        self.celebrity = celebrity
        
        self.isFollowed     = celebrity.isFollowed
        self.followersCount = celebrity.followersCount
        
        self.subscriptionCancellable = SGAppSession.shared.subscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] _ in
                self?.isSubscribed = SGAppSession.shared.canMessage(with: celebrity.id)
            })
    }
    
    func toggleFollow() {
        if isFollowed {
            self.isFollowed = false
//            self.followersCount -= 1
            
            SGUserService.unFollow(userID: "\(celebrity.id)")
                .sink { result in
                    switch result {
                    case .finished: break
                    case .failure(let error): self.error = error
                    }
                    
                } receiveValue: { followResult in
                    self.followersCount = followResult.followersCount
                }
                .store(in: &cancellables)
        }
        
        else {
            self.isFollowed = true
//            self.followersCount += 1
            
            SGUserService.follow(userID: "\(celebrity.id)")
                .sink { result in
                    switch result {
                    case .finished: break
                    case .failure(let error):
                        switch error {
                        case .cancelled : break
                        default: self.error = error
                        }
                    }
                    
                } receiveValue: { followResult in
                    self.followersCount = followResult.followersCount
                }
                .store(in: &cancellables)
        }
        
        //TODO:- Call API here
    }
    
    func getDetails() {
        guard self.shouldRefresh
        else { return }
        
        isLoading = true
        
        SGCelebrityService.fetchDetail(for: id)
            .sink {[weak self] result in
                self?.isLoading = false
                switch result {
                case .failure(let error):
                    self?.error = error
                    
                default: break
                }
            } receiveValue: {[weak self] updatedCelebrity in
                self?.celebrity = updatedCelebrity
                self?.isFollowed     = updatedCelebrity.isFollowed
                self?.followersCount = updatedCelebrity.followersCount
                self?.isLoading = false
                self?.shouldRefresh = false
                
            }
            .store(in: &cancellables)
    }
    
    func generateShareLink(completion: @escaping (URL?)->()) {
        
        guard var basePath = URL(string: "https://stargazeevent.page.link/celeb")
        else {
            completion(nil)
            return
        }
        
        if #available(iOS 16.0, *) {
            basePath.append(component: "\(self.id)")
        } else {
            // Fallback on earlier versions
            basePath.appendPathComponent("\(self.id)")
        }
        let prefix = "https://stargazeevent.page.link"
        
        let linkBuilder = DynamicLinkComponents(link: basePath,
                                                domainURIPrefix: prefix)
        
        //Metadata
        let metaData = DynamicLinkSocialMetaTagParameters()
        metaData.title = self.name
        metaData.descriptionText = self.bio
        
        if let url = picURL {
            metaData.imageURL = url
        }
        
        //iOS Parameter
        if let bundleID = Bundle.main.bundleIdentifier, !bundleID.isEmpty {
            let iOSParameter = DynamicLinkIOSParameters(bundleID: bundleID)
//            iOSParameter.minimumAppVersion = Bundle.main.releaseVersionNumber
            
#if PROD
            iOSParameter.appStoreID = "1573361691"
#else
            iOSParameter.appStoreID = "1645083991"
#endif
            
            linkBuilder?.iOSParameters = iOSParameter
        }
        
        let androidParameters = DynamicLinkAndroidParameters(packageName: "com.stargaze")
        androidParameters.minimumVersion = 0
          
        let navigationInfoParameter = DynamicLinkNavigationInfoParameters()
        navigationInfoParameter.isForcedRedirectEnabled = true
                
        linkBuilder?.socialMetaTagParameters = metaData
        linkBuilder?.androidParameters = androidParameters
        linkBuilder?.navigationInfoParameters = navigationInfoParameter

        linkGenerating = true
        linkBuilder?.shorten(completion: {[weak self] url, warnings, error in
            self?.linkGenerating = false
            if let url = url {
                completion(url)
            }
            else {
                print("Feed share link failed \(error?.localizedDescription ?? "")")
            }
        })
    }
}

extension SGCelebrityViewModel: Hashable {
    static func == (lhs: SGCelebrityViewModel, rhs: SGCelebrityViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension SGCelebrityViewModel {
    func block() {
        let celebID = self.celebrity.id
        
        SGAlertUtility.showHUD()
        SGUserService.block(userID: "\(celebID)")
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    self?.error = error
                }
            } receiveValue: {[weak self] didBlock in
                SGAlertUtility.hidHUD()
                self?.isBlocked = true
                if didBlock {
                    let info = [AppUpdateNotificationKey.updateType: AppUpdateType.celebBlocked(celebID)]
                    NotificationCenter.default.post(name: .celebrityBlocked,
                                                    object: nil,
                                                    userInfo: info)
                }
                else {
                    self?.error = SGAPIError.custom("Failed to block the user. Try again later.")
                }
            }
            .store(in: &cancellables)

    }
}
