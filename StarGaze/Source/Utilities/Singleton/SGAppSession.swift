//
//  SGAppSession.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine
import FirebaseMessaging

class SGAppSession: NSObject {
    var token: String?
//    var user: UserDetail?
    
    let user = CurrentValueSubject<UserDetail?, Never>(nil)
    let wallet = CurrentValueSubject<Wallet?, Never>(nil)
    let subscriptions = CurrentValueSubject<[SubscriptionItem], Never>([])
    let payload = CurrentValueSubject<APNSPayload?, Never>(nil)
    
//    var payload: APNSPayload? = nil
    
    private var fcmObserver: AnyCancellable? = nil
    
    static var shared: SGAppSession = {
        return SGAppSession()
    }()
    
    func canComment(on celebID: Int) -> Bool {
        guard celebID != user.value?.id
        else { return true }
        
        let hasCommentSubscription: Bool = (subscriptions.value.first(where: { $0.type == .comment }) != nil)  
        let hasCelebSubscription: Bool = hasSubscription(for: celebID)
        
        let canComment = hasCommentSubscription || hasCelebSubscription
        return canComment
    }
    
    func canMessage(with celebID: Int) -> Bool {
        guard celebID != user.value?.id
        else { return true }
        
        let hasCelebSubscription = hasSubscription(for: celebID)
        let canMessage: Bool = hasCelebSubscription
        return canMessage
    }
    
    func hasSubscription(for celebID: Int) -> Bool {
        guard celebID != user.value?.id
        else { return true }
        
        let isAppUnlocked: Bool = (subscriptions.value.first(where: { $0.type == .appUnlock }) != nil)
        let hasCelebSubscription: Bool = (subscriptions.value.first(where: { $0.celeb?.id == celebID }) != nil)
        
        let hasSubscription: Bool = hasCelebSubscription || isAppUnlocked
        return hasSubscription
    }
    
    func cleanup() {
        token = nil
        user.send(nil)
        wallet.send(nil)
        subscriptions.send([])
        
        SGUserDefaultStorage.clearData()
        
        fcmObserver?.cancel()
        fcmObserver = nil
    }
    
    //MARK: - APNS
    func registerForRemoteNotification() {
        
        if #available(iOS 10.0, *) {
              // For iOS 10 display notification (sent via APNS)
              UNUserNotificationCenter.current().delegate = self

              let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
              UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
              )
            } else {
              let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }

        UIApplication.shared.registerForRemoteNotifications()
        
        
//        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func saveDeviceToken(_ token: Data) {
        guard !token.isEmpty
        else { return }
        
        let messaging = Messaging.messaging()
        messaging.delegate = self
        messaging.apnsToken = token
        
        messaging.token {[weak self] token, error in
            if token != nil {
                self?.saveFCM(fcmToken: token)
            }
        }
    }
    
    func handleNotification(_ notification:[AnyHashable: Any]) {
        guard let dict = notification as? [String: Any]
        else { return }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            let payload = try JSONDecoder().decode(APNSPayload.self, from: data)
            
            DispatchQueue.main.async {[weak self] in
                if UIApplication.shared.applicationState == .active {
                    self?.handlePayload(payload)
                }
                else {
                    self?.payload.send(payload)
                }
            }                        
        }
        catch {
            print("APNS Payload error \(error)")
        }        
    }
    
    func handlePayload(_ payload: APNSPayload) {
        if let notificationID = payload.notifId {
            Task {
                await NotificationService().markRead(for:.init(id: notificationID)) //Marking the notification as read
            }
        }
        
        
        guard let id = Int(payload.id)
        else { return }
        
        var type: AppRedirectType? = nil
        switch payload.type {
        case .feed, .poll:
            type = .feed(id)
        case .event, .show:
            type = .event(id)            
        case .celeb:
            type = .celebrity(id)
        }
        
        if let type = type {
            let userInfo = [NotificationUserInfoKey.redirectType : type]
            NotificationCenter.default
                .post(name: .redirectApp, object: nil, userInfo: userInfo)
        }
    }
    
    func handleShareLink(_ url:URL) {
        var host: String? = nil
        if #available(iOS 16.0, *) {
            host = url.host()
        } else {
            host = url.host
            // Fallback on earlier versions
        }
        
        guard let host = host, host == "stargazeevent.page.link"
        else { return }
        
        var components = url.pathComponents
        components.removeAll(where: { $0 == "/" })
        
        
        let type = components.first
        let id = url.lastPathComponent
        
        guard let type = type
        else { return }
        
        var payload: APNSPayload? = nil
        
        switch type {
        case "feeds": payload = APNSPayload(type: .feed, id: id, notifId: nil)
        case "event": payload = APNSPayload(type: .event, id: id, notifId: nil)
        case "celeb": payload = APNSPayload(type: .celeb, id: id, notifId: nil)
        default: break
        }
        
        guard let payload = payload
        else { return  }
        
        DispatchQueue.main.async {[weak self] in
            if UIApplication.shared.applicationState == .active {
                self?.handlePayload(payload)
            }
            else {
                self?.payload.send(payload)
            }
        }        
    }
    
    
    private func saveFCM(fcmToken: String?) {
        if let token = fcmToken, !token.isEmpty {
            let request = FirebaseMessagingRequest(token: token,
                                                   platform: .iOS)
            
            fcmObserver = NotificationService.registerFirebaseToken(request: request)
                .sink(receiveCompletion: { result in
                    switch result {
                    case .finished: break
                    case .failure(let error):
                        debugPrint("Failed to register FCM \(error)")
                    }
                }, receiveValue: { didRegister in
                        debugPrint("FCM didRegister \(didRegister)")
                })
        }
    }
}

extension SGAppSession: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        saveFCM(fcmToken: fcmToken)
    }
}

extension SGAppSession: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner]
    }
    
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        self.handleNotification(userInfo)
    }
}
