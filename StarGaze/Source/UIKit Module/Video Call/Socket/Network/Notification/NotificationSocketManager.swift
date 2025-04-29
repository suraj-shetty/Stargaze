//
//  NotificationSocketManager.swift
//  StargazeSocket
//
//  Created by Suraj Shetty on 06/08/22.
//

import UIKit
import Combine
class NotificationSocketManager: NSObject {
    static let shared = NotificationSocketManager()
    
    private var socket:SocketConection?
    private var cancellables = Set<AnyCancellable>()
    
//    func connect() {
//        if let current = socket {
//            for cancellable in cancellables {
//                cancellable.cancel()
//            }
//            cancellables.removeAll()
//            current.disconnect()
//        }
//        
//        let token = //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTQsImlhdCI6MTY1OTc4ODIzNX0.TsW9ocS1BbaEssmt9gnZkara1AnQT7QB7ezGGbKHqJE"
//        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTI5LCJpYXQiOjE2NTk3ODc0ODl9.uVC0KDk34gSaQIK5FDq6igk-3raxUkeNiSLSVRuq5eU"
//        
//        let connectionInfo = SocketConnectionInfo(url: URL(string: "http://stargaze-notification-qa.us-east-2.elasticbeanstalk.com/notification")!,
//                                                  nameSpace: "/notification",
//                                                  token: token)
//        let connection = SocketConection()
//        connection.messagePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                switch completion {
//                case .failure(_): print("Socket subject failure")
//                case .finished: print("Socket subject finished")
//                }
//            } receiveValue: {[weak self] response in
//                self?.processResponse(response)
//            }
//            .store(in: &cancellables)
//
//        connection.connect(with: connectionInfo)
//
//        self.socket = connection
//        
//    }
    
    private func processResponse(_ response: SocketResponse) {
        switch response {
        case .message(let socketMessage):
            print("**** Notifcation MessageReceived \(socketMessage.event), \(socketMessage.data?.description ?? "")")
//            handleMessage(socketMessage)
            
        case .error(let error):
            print("**** Notification Error Received \(error)")
        }
    }
    
    private func handleMessage(_ message: SocketMessage) {
        switch message.event {
        case "connect":
            let request = NSMutableDictionary()
            request.setValue([86, 83, 81, 76, 75, 74],
                              forKey: "rooms")
            request.setValue("event", forKey: "service")
            
            self.socket?.send(SocketEmitMessage(event: "join_room",
                                                data: request))
            
        default: break;
        }
    }
}
