//
//  EventSocketManager.swift
//  StargazeSocket
//
//  Created by Suraj Shetty on 06/08/22.
//

import UIKit
import Combine
import SocketIO

enum EventSocketEventType: String {
    case counter = "event_realtime_counter"
    case probabilityUpdate = "probability_update"
    case eventUpdate = "event_update"
    case notification = "notification"
}

enum EventSocketMessage {
    case counter(EventCounterUpdate)
    case probabilityUpdate(EventProbabilityUpdate)
    case eventUpdate(EventUpdate)
    case notification
    case error(Error)
}


class EventSocketManager: NSObject {
    static let shared = EventSocketManager()
    
    let messageSubscriber = PassthroughSubject<EventSocketMessage, Never>()
    
    private var socket:SocketConection?
    private var cancellables = Set<AnyCancellable>()
    private(set) var isConnected: Bool = false
    
    private var rooms = [Int]()
}

extension EventSocketManager {
    func connect(with events: [Event]) {
        if let current = socket {
            for cancellable in cancellables {
                cancellable.cancel()
            }
            cancellables.removeAll()
            current.disconnect()
        }
        
        self.rooms = events.map({ $0.id })
        
        var urlComponent = URLComponents()
        urlComponent.host = URLEndPoints.baseURL_Event
        urlComponent.path = "/event"
        urlComponent.scheme = "https"
                        
        let connectionInfo = SocketConnectionInfo(url: urlComponent.url!,
                                                  nameSpace: "/event",
                                                  headers: ["token": SGAppSession.shared.token ?? ""])
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
    
    func close() {
        cancellables.forEach({ $0.cancel() })
        socket?.disconnect()
    }
    
    func startListening(events:[Event]) {
        let eventIDs = Set(events.map({ $0.id }))
        let currentRooms = Set(rooms)
        
        let common = eventIDs.intersection(currentRooms)
        let roomsToLeave = currentRooms.subtracting(common)
        let roomsToJoin = eventIDs.subtracting(common)
        
        if !roomsToLeave.isEmpty, isConnected {
            leaveRooms(rooms: Array(roomsToLeave))
        }
        if !roomsToJoin.isEmpty, isConnected {
            joinRooms(rooms: Array(roomsToJoin))
        }
        
        self.rooms = Array(common.union(roomsToJoin))
    }
    
    func stopListening(events:[Event]) {
        let eventIds = events.map({ $0.id })
        leaveRooms(rooms: eventIds)
        
        self.rooms.removeAll(where: { eventIds.contains($0) })
    }
}

private extension EventSocketManager {
    func processResponse(_ response: SocketResponse) {
        switch response {
        case .message(let socketMessage):
//            print("****Event MessageReceived \(socketMessage.event), \(socketMessage.data?.description ?? "")")
            handleMessage(socketMessage)
            
        case .error(let error):
            print("****Event Error Received \(error)")
        }
    }
    
    func handleMessage(_ message: SocketMessage) {
        if let clientEvent = SocketClientEvent(rawValue: message.event) {
//            print("Event Socket -> client event received")
            
            switch clientEvent {
            case .connect:
                self.isConnected = true
                if !rooms.isEmpty {
                    joinRooms(rooms: rooms)
                }
                
            case .disconnect:
                self.isConnected = false
                
            case .error:
                self.isConnected = false
                
            default: break
            }
        }
        else if let event = EventSocketEventType(rawValue: message.event) {
            print("Event Socket -> Received predefined event \(message.event)")
            
            if let data = message.data?.last {
                print("Event Socket -> predefined event data \(data)")
                let eventMessage = getResponse(from: data, for: event)
                messageSubscriber.send(eventMessage)
            }
        }
        else {
            print("Event Socket -> Unknown event received")
            print(message.event)
            if let data = message.data {
                print(data)
            }
        }
    }
    
    func getResponse(from data: Any, for event: EventSocketEventType) -> EventSocketMessage {
        switch event {
        case .counter:
            do {
                let result: EventCounterUpdate = try convertResponse(response: data)
                return .counter(result)
            }
            catch {
                print("Invalid Counter message \(data)")
                return .error(error)
            }
            
        case .probabilityUpdate:
            do {
                let result: EventProbabilityUpdate = try convertResponse(response: data)
                return .probabilityUpdate(result)
            }
            catch {
                print("Invalid probability message \(data)")
                return .error(error)
            }
            
        case .eventUpdate:
            do {
                let result: EventUpdate = try convertResponse(response: data)
                return .eventUpdate(result)
            }
            catch {
                print("Invalid event update message \(data)")
                return .error(error)
            }
            
        case .notification:
            return .notification
        }
        
    }
    
    func convertResponse<T: Codable>(response: Any) throws -> T {
        do {
            let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            let result = try JSONDecoder().decode(T.self, from: data)
            
            return result
        }
        catch {
            print("JSON error \(error)")
            throw VideoCallError.responseError
        }
    }
    
    //MARK: -
    func joinRooms(rooms: [Int]) {
        let message = SocketEmitMessage(event: "join_room",
                                        data: ["rooms" : rooms])
        socket?.send(message)
    }
    
    func leaveRooms(rooms: [Int]) {
        let message = SocketEmitMessage(event: "leave_room",
                                        data: ["rooms" : rooms])
        socket?.send(message)
    }
}
