//
//  SocketConnection.swift
//  StargazeSocket
//
//  Created by Suraj Shetty on 06/08/22.
//

import Foundation
import Combine
import SocketIO

struct SocketConnectionInfo {
    let url: URL
    let nameSpace: String
    let headers:[String:String]?
}

struct SocketMessage {
    let event: String
    let data: [Any]?
}

enum SocketResponse {
    case message(SocketMessage)
    case error(Error)
}

struct SocketEmitMessage {
    let event: String
    let data: SocketData!
}

class SocketConection: NSObject {
    private(set) var info: SocketConnectionInfo!
    private(set) var isConnected: Bool = false
    let messagePublisher = PassthroughSubject<SocketResponse, Never>()
        
    private var socketManager: SocketManager?
    
    func connect(with info: SocketConnectionInfo) {
        if let socket = socketManager, socket.status == .connected {
            socket.disconnect()
        }
        
        //Setting up a new connection
        self.info = info
        var configuration: SocketIOClientConfiguration = [
            .log(false),
            .forceNew(true),
            .compress,
            .forceWebsockets(true),
            .secure(true)
        ]
        
        if let headers = info.headers, !headers.isEmpty {
            configuration.insert(.extraHeaders(headers))
        }
                
        let manager = SocketManager(socketURL: info.url,
                                   config: configuration)
        let socket = manager.socket(forNamespace: info.nameSpace)
        
//        socket.on("test") { data, ack in
//            print("Test message received")
//            print("Data:\(data), ack:\(ack)")
//        }
        
        
        socket.on(clientEvent: .connect) {[weak self] data, _ in
//            print("Connected \(data)")
            self?.isConnected = true
////            if let token = self?.info.token {
////
////            }
//
////            manager.defaultSocket.emit("40", ["token" : token])
//
//            let request = NSMutableDictionary()
//            request.setValue([142, 127, 122, 103, 90, 88, 86, 83, 81, 80, 398, 390, 389, 387, 386, 385, 384, 383, 379, 374, 76, 75, 74, 70, 11],
//                              forKey: "rooms")
//            request.setValue("social", forKey: "service")
//
//            manager.defaultSocket.emit("join_room", request)
            
        }
        
        socket.on(clientEvent: .disconnect) {[weak self] _, _ in
            self?.isConnected = false
        }
        
        socket.on(clientEvent: .error) {[weak self] data, _ in
//            print("Received error \(data)")
            self?.isConnected = false
            
            if let error = data.first as? Error {
                self?.messagePublisher.send(.error(error))
            }
        }
        
        socket.onAny {[weak self] event in
//            print("Received On any \(event)")
//            print("data:\(data) Ack:\(ack)")
            let message = SocketMessage(event: event.event,
                                        data: event.items)
            self?.messagePublisher
                .send(.message(message))
        }
        
        
//        socket.on(clientEvent: .pong) { data, ack in
//            print("Received Pong")
//            print("data:\(data) Ack:\(ack)")
//
//            socket.emit("ping_me", ["celebStreamId":"123"])
//        }
        
//        socket.on(clientEvent: .ping) { data, ack in
//            print("Received Ping")
//            print("data:\(data) Ack:\(ack)")
//        }
        
//        socket.onAny {[weak self] event in
//            print("Received \(event)")
////            print("data:\(data) Ack:\(ack)")
////            let message = SocketMessage(event: event.event,
////                                        data: event.items)
////            self?.messagePublisher
////                .send(.message(message))
//        }
        
//        if let token = info.token {
//            manager.defaultSocket.connect(withPayload: [
//                "jsonp" : true,
//                "auth" : ["token": token]
//            ])
//        }
//        else {
//            manager.defaultSocket.connect(withPayload: [
//                "jsonp" : true
//            ])
//        }
        socket.connect()
        self.socketManager = manager
    }
    
    func disconnect() {
        self.socketManager?.disconnect()
        self.socketManager = nil
        self.isConnected = false
    
    }
    
    func send(_ message: SocketEmitMessage) {
//        print("\(Date()) Sending message \(message.event)")
//        if let data = message.data {
//            print("With data \(data)")
//        }
        
        let messageData: SocketData = message.data ?? []
        socketManager?.socket(forNamespace: info.nameSpace)
            .emit(message.event,
                  messageData)
        
        
    }
    
}
