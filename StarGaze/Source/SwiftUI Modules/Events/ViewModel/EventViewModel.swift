//
//  EventViewModel.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import FirebaseDynamicLinks

final class EventViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var linkGenerating: Bool = false
    
    //MARK: -
    func shareLink(for event: Event, completion: @escaping (URL?)->()) {
        
        guard var basePath = URL(string: "https://stargazeevent.page.link/event")
        else {
            completion(nil)
            return
        }
        
        if #available(iOS 16.0, *) {
            basePath.append(component: "\(event.id)")
        } else {
            // Fallback on earlier versions
            basePath.appendPathComponent("\(event.id)")
        }
        let prefix = "https://stargazeevent.page.link"
        
        let linkBuilder = DynamicLinkComponents(link: basePath,
                                                domainURIPrefix: prefix)
        
        //Metadata
        let metaData = DynamicLinkSocialMetaTagParameters()
        metaData.title = event.title
        metaData.descriptionText = event.description
        
        if let url = URL(string: event.mediaPath) {
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
        
        let navigationInfoParameter = DynamicLinkNavigationInfoParameters()
        navigationInfoParameter.isForcedRedirectEnabled = true
        
        let androidParameters = DynamicLinkAndroidParameters(packageName: "com.stargaze")
        androidParameters.minimumVersion = 0
                
        linkBuilder?.socialMetaTagParameters = metaData
        linkBuilder?.androidParameters = androidParameters
        linkBuilder?.navigationInfoParameters = navigationInfoParameter

//        guard let shareURL = linkBuilder?.url
//        else {
//            completion(nil)
//            return
//        }
           
        
        linkGenerating = true
        linkBuilder?.shorten(completion: {[weak self] url, warnings, error in
            self?.linkGenerating = false
            if let url = url {
                completion(url)
            }
            else {
//                self?.error = .custom("Failed to generate share link")
                print("Feed share link failed \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    // MARK: - Networking
    func likeEvent(isLiked: Bool, eventId: Int, completion: @escaping (Event?) -> Void) {
        SGEventService.likeEvent(isLiked: isLiked, eventId: eventId)
            .sink { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.showErrorAlert(message: error.errorDescription)
                    break
                case .finished:
                    break
                }
            } receiveValue: {[weak self] _ in
                self?.getEvent(eventId: eventId, completion: completion, showIndicator: false)
            }
            .store(in: &cancellables)
    }
    
    func joinEvent(coinType: String, eventId: Int, completion: @escaping (Event?) -> Void) {
        SGAlertUtility.showHUD()
        SGEventService.joinEvent(coinType: coinType, eventId: eventId)
            .sink { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    SGAlertUtility.showErrorAlert(message: error.errorDescription)
                    break
                case .finished:
                    break
                }
            } receiveValue: {[weak self] response in
                NotificationCenter.default.post(name: .updateWallet, object: nil)
                self?.getEvent(eventId: eventId, completion: completion)
            }
            .store(in: &cancellables)
    }
    
    private func getEvent(eventId: Int, completion: @escaping (Event?) -> Void, showIndicator: Bool = true) {
        if showIndicator {
            SGAlertUtility.showHUD()
        }
        SGEventService.getEvent(eventId: eventId)
            .sink { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    SGAlertUtility.showErrorAlert(message: error.description)
                    break
                case .finished: break
                }
            } receiveValue: { response in
                SGAlertUtility.hidHUD()
                completion(response.result)
            }
            .store(in: &cancellables)
    }
    
    func incrementShareCount(for event: Event,
                             completion: @escaping (Event?)-> Void) {
        SGEventService.share(eventID: event.id)
            .sink { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    SGAlertUtility.showErrorAlert(message: error.errorDescription)
                    break
                case .finished:
                    break
                }
            } receiveValue: { didIncrement in
                if didIncrement {
//                    event.shareCount += 1
                    
                }
            }
            .store(in: &cancellables)

    }
    
}
