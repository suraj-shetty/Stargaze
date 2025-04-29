//
//  SocialSocketManager.swift
//  StargazeSocket
//
//  Created by Suraj Shetty on 06/08/22.
//

import Foundation
import Combine

class SocialSocketManager: NSObject {
    static let shared = SocialSocketManager()
    
    private var socket:SocketConection?
    private var cancellables = Set<AnyCancellable>()
    
    func connect() {
        if let current = socket {
            for cancellable in cancellables {
                cancellable.cancel()
            }
            cancellables.removeAll()
            current.disconnect()
        }
        
        let token = //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTQsImlhdCI6MTY1OTc4ODIzNX0.TsW9ocS1BbaEssmt9gnZkara1AnQT7QB7ezGGbKHqJE"
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjgzLCJpYXQiOjE2NjAwNTEwNTR9.feQPS4IO41BughXkzF9880Qp02XhGt98jQUEcrMg69s"
        
        let connectionInfo = SocketConnectionInfo(url: URL(string: "https://api-social-dev.stargaze.ai/social")!,
                                                  nameSpace: "/social",
                                                  headers: ["token": token])
        let connection = SocketConection()
        connection.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(_): print("Socket subject failure")
                case .finished: print("Socket subject finished")
                }
            } receiveValue: {[weak self] response in
                self?.processResponse(response)
            }
            .store(in: &cancellables)

        connection.connect(with: connectionInfo)

        self.socket = connection
        
    }
    
    private func processResponse(_ response: SocketResponse) {
        switch response {
        case .message(let socketMessage):
            print("**** MessageReceived \(socketMessage.event), \(socketMessage.data?.description ?? "")")
            handleMessage(socketMessage)
            
        case .error(let error):
            print("**** Error Received \(error)")
        }
    }
    
    private func handleMessage(_ message: SocketMessage) {
        switch message.event {
        case "connect":
            let request = NSMutableDictionary()
            request.setValue([320, 319, 318, 317, 316, 315],
                              forKey: "rooms")
            request.setValue("social", forKey: "service")
            
            self.socket?.send(SocketEmitMessage(event: "join_room",
                                                data: request))
            
        default: break;
        }
    }
}
