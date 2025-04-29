//
//  NotificationViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 20/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

@MainActor
class NotificationViewModel: ObservableObject, Identifiable {
    var notification: AppNotification
    weak var apiService: NotificationService?
    
    @Published var isRead: Bool = false
    
    init(notification: AppNotification) {
        self.notification = notification
        self.isRead = notification.didRead
    }
    
//    var id: Int {
//        get {
//            return notification.id
//        }
//    }
    
    func markAsRead() async {
        let request = NotificationReadRequest(id: notification.id)
        guard let result = await apiService?.markRead(for: request)
        else { return }
        
        switch result {
        case .success(_):
            notification.didRead = true
            self.isRead = true
            
        case .failure(_):
            break
        }
    }
    
    func open() {
        guard let type = notification.type, let typeID = notification.typeID
        else { return }
        
        let payload = APNSPayload(type: type,
                                  id: String(typeID),
                                  notifId: nil)
        SGAppSession.shared.handlePayload(payload)
    }
}
