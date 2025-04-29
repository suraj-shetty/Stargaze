//
//  VideoCallSocketManager.swift
//  StargazeSocket
//
//  Created by Suraj Shetty on 09/08/22.
//

import Foundation
import Combine
import SocketIO

enum SocketEventType: String {
    case celebStartCall = "celeb_start_call"
    case celebReady     = "celeb_ready"
    case celebPaused    = "celeb_pause"
    case celebLeft      = "celeb_left"
    case celebShowEnd   = "celeb_show_complete"
    case winnerGetPass  = "winner_before_join_get_pass"
    case winnerJoinNow = "winner_join_now"
    case winnerJoined   = "winner_joined"
    case winnerLeft     = "winner_left"
    
    case eventStreamUpdate  = "update_stream"
    case viewerCount    = "viewer_count"
    
    case eventComplete  = "event_completed"
}

enum VideoCallEvent {
    case celebStartCall(CallDetails)
    case celebReady(CallInfo)
    case celebJoined(CallEventInfo)
    case celebPaused
    case celebLeft
    
    case winnerJoined(CallJoinedInfo)
    case winnerLeft
    
    case callPass(CallPassInfo)
    case callJoin(CallJoinInfo)
    case viewerCount(CallViewerCount)
    
    case callEnded(CallEventCompleteInfo)
    case error(Error)
    
    case streamUpdate
}

enum VideoCallMessage {
    case system(SocketClientEvent)
    case event(VideoCallEvent)
}

enum VideoCallError: Error {
    case responseError
    case invalidDataError
    
    var description: String {
        switch self {
        case .responseError:
            return "Failed to convert socket message to response"
            
        case .invalidDataError:
            return "Invalid data received over socket"
        }
    }
}


class VideoCallSocketManager: NSObject {
    static let shared = VideoCallSocketManager()
    
    let messageSubject = PassthroughSubject<VideoCallMessage, Never>()
    
    private var socket:SocketConection?
    private var cancellables = Set<AnyCancellable>()
    
    private var eventID: Int = -1
    private var celebID: Int = -1
    private var userID: Int = -1
    
    private var timer: Timer?
    
    var isConnected: Bool {
        get { return socket?.isConnected ?? false }
    }
    
    func connect(to room: VideoCallRoom) {
        if let current = socket {
            for cancellable in cancellables {
                cancellable.cancel()
            }
            cancellables.removeAll()
            current.disconnect()
            
            timer?.invalidate()
        }
        
        self.eventID = room.eventID
        self.celebID = room.celebrityID
        self.userID = room.userID
                        
        var urlComponent = URLComponents()
        urlComponent.host = URLEndPoints.baseURL_Event
        urlComponent.path = "/video-call"
        urlComponent.scheme = "https"
        
        let connectionInfo = SocketConnectionInfo(url: urlComponent.url!,
                                                  nameSpace: "/video-call",
                                                  headers: ["token": room.userToken,
                                                            "eventId": "\(eventID)"])
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
    
    func disconnect() {
        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables.removeAll()
        socket?.disconnect()
        
        timer?.invalidate()
    }
    
    private func processResponse(_ response: SocketResponse) {
        switch response {
        case .message(let socketMessage):
//            print("****Event MessageReceived \(socketMessage.event), \(socketMessage.data?.description ?? "")")
            handleMessage(socketMessage)
            
        case .error(let error):
            print("****Event Error Received \(error)")
        }
    }
    
    private func handleMessage(_ message: SocketMessage) {
//        debugPrint("Video call \(message.event) \(message.data)")
        
        if let socketEvent = SocketClientEvent(rawValue: message.event) { //System Event
            //TODO: - Return system event
            //print("\n\n\n")
            
            switch socketEvent {
            case .connect:
                //Send back Connected status
                if celebID == userID { //Celebrity's socket session is ready, send ready status to all participants
                    startCall()
                }
                                
            case .disconnect:
                print("Socket disconnected")
            case .error:
                print("Socket connect error")
            case .ping: break
//                print("Socket ping")
            case .pong: break
//                print("Socket pong")
            case .reconnect:
                print("Socket reconnect")
            case .reconnectAttempt:
                print("Socket reconnect attempt")
            case .statusChange:
                print("Socket status changed")
            case .websocketUpgrade: break
//                print("Socket upgrade")
            }
            //print("System event data \(message.data?.description ?? "Empty data")")
            //print("\n\n\n")
            
            messageSubject.send(.system(socketEvent))
            return
        }
        
        if let eventType = SocketEventType(rawValue: message.event) {
            print("\n")
            print("Received predefined event \(message.event)")
            print("Data \(message.data?.description ?? "Empty data")")
            print("\n")
            
            var response: VideoCallEvent?
            if let data = message.data?.first {
                let message = getResponse(from: data, for: eventType)
                response = message
            }
            
            //Handling predefined events
            switch eventType {
            case .celebStartCall: //Only Celebrity receives this
                //Here once the video controller receives this, it'll initiate the call session. Once that's done, it needs to call joinCall
                break
//                if let response = response {
//                    switch response {
//                    case .celebStartCall(let callDetails):
//                        if callDetails.eventID == "\(self.eventID)" {
//                            joinCall() //Since celebrity did start call, notify other in socket
//                        }
//
//                    default: break
//                    }
//                }
                
            case .celebReady: //Only participants receives this
                if celebID != userID, let response = response {
                    switch response {
                    case .celebReady(_): break
//                        print("User received Celeb ready")
                        
                    case .celebJoined(let info):
                        if info.eventID == "\(self.eventID)" {
                            //print("Celeb joined")
                        }
                    default:
                        break
                    }
                }
                else {
                    //print("Celebrity received celeb ready")
                }
                                                
                
            case .celebPaused:
                print("Celebrity paused")
                
            case .celebLeft:
                print("Celebrity left Event")
                //TODO: - Handle call end flow
//                stopTimer()
//                leaveCall(didPause: false)
                
            case .celebShowEnd:
                print("Celeb Show end called")
                
            case .winnerGetPass:
                if userID == celebID {
//                    print("Celebrity-> winner get pass received")
                    return //No need to send message
                }
                else {
//                    print("User-> winner get pass received")
                                       
                    //TODO: - send received message to the video call flow
                    let message = SocketEmitMessage(event: SocketEventType.winnerJoined.rawValue,
                                                    data: "")
                    socket?.send(message)
//                    startTimer()
                    
                    //print("Winner joined event sent")
                }
                
                
            case .winnerJoinNow:
                if userID == celebID {
//                    print("Celebrity received winner join now event")
                }
                else {
//                    print("User received winner join now")
                    if let response = response {
                        switch response {
                        case .callJoin(let info):
                            if info.eventID == "\(self.eventID)" {
                                if info.connect {
                                    //TODO: - Check and mark current user as winner
                                    //if winner, send get pass event, else stop timer and notify not winner
                                    let message = SocketEmitMessage(event: SocketEventType.winnerGetPass.rawValue,
                                                                    data: nil)
                                    socket?.send(message)
                                    //print("Sent get pass event")
                                }
                                else {
//                                    stopTimer() //Call ended for current winner
                                }
                            }
                            
                        default: break
                        }
                    }
                }
                
                
                
            case .winnerJoined:
//                if celebID == userID {
//                    print("Celebrity received winner joined event")
//                }
//                else {
//                    print("User received winner joined event")
//                }
                
                if let response = response {
                    switch response {
                    case .winnerJoined(let info):
                        guard info.eventID == self.eventID
                        else { return } //Ignore other event messages
                        
                    default: break
                    }
                }
                
                
//            case .winnerLeft:
//                print("Event winner left")
//
//            case .eventStreamUpdate:
//                print("Stream update event received")
//
//            case .viewerCount:
//                print("Viewer count update received")
                
            case .eventComplete: break
//                print("Event complete received")
//                stopTimer()
                //TODO: - Close all sessions
//                messageSubject.send(completion: Subscribers.Completion<Never>)
//                socket?.disconnect()
                
            default: break
                
            }
            
            if let response = response {
                messageSubject.send(.event(response))
            }
            return
        }
        
        //Custom Event
        switch message.event {
        case "unhandled_exception":
//            print("Exception raised")
            break
                        
            
//            let request = NSMutableDictionary()
//            request.setValue([86, 83, 81, 76, 75, 74],
//                              forKey: "rooms")
//            request.setValue("event", forKey: "service")
//
//            self.socket?.send(SocketEmitMessage(event: "join_room",
//                                                data: request))
            
        default:
            print("Unknown event received \(message.event)  \(message.data?.description ?? "Empty data")")
            break
        }
    }
    
    
}

private extension VideoCallSocketManager {
    func startTimer() {
        if timer?.isValid == true {
            timer?.invalidate() //Ending any active timer running
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true, block: {[weak self] _ in
            let message = SocketEmitMessage(event: "timer_call", data: nil)
            self?.socket?.send(message)
            
            //print("Timer ping sent")
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func getResponse(from response: Any, for event:SocketEventType) -> VideoCallEvent {
//        let decoder = JSONDecoder()
        //print("Resonse \(response)")
        
        switch event {
        case .celebStartCall:
            do {
                let result:CallResponse<CallDetails> = try self.convertResponse(response: response)
                let details = result.result
                
                return .celebStartCall(details)
            }
            catch {
                return .error(error)
            }
            
        case .celebReady: //User receives two kind of response for celeb_ready
            if let json = response as? [String: Any],
               var result = json["result"] as? [String: Any] {
            
                var eventID: String? = nil
                
                if let id = result["eventId"] as? String {
//                    print("Celeb ready, received eventID as String")
                    eventID = id
                }
                else if let id = result["eventId"] as? Int {
//                    print("Celeb ready, received eventID as Int")
                    eventID = "\(id)"
                    result["eventId"] = "\(id)"
                }
                
                if eventID == "\(self.eventID)" {
                    if result.keys.contains("token") { //Has Call session details
                        do {
                            let result: CallInfo = try convertResponse(response: result)
//                            let info = result.result
                            return .celebReady(result)
                        }
                        catch {
                            return .error(error)
                        }
                    }
                    else {
                        do {
                            let result: CallEventInfo = try convertResponse(response: result)
//                            let info = result.result                            
                            return .celebJoined(result)
                        }
                        catch {
                            return .error(error)
                        }
                    }
                }
                else {
                    print("Received eventID of another event")
                    return .error(VideoCallError.invalidDataError)
                }
            }
            else {
//                print("Celeb ready error \(response)")
                return .error(VideoCallError.invalidDataError)
            }
                        
//            if let json = response as? [String: Any],
//               let result = json["result"] as? [String: Any],
//               let eventID = result["eventId"] as? String,
//               eventID == "\(self.eventID)" {
//
//                if result.keys.contains("token") { //Has Call session details
//                    do {
//                        let result: CallResponse<CallInfo> = try convertResponse(response: response)
//                        let info = result.result
//
//                        return .celebReady(info)
//                    }
//                    catch {
//                        return .error(error)
//                    }
//                }
//                else {
//                    do {
//                        let result: CallResponse<CallEventInfo> = try convertResponse(response: response)
//                        let info = result.result
//
//                        return .celebJoined(info)
//                    }
//                    catch {
//                        return .error(error)
//                    }
//                }
//            }
//            else {
//                print("Celeb ready error \(response)")
//                return .error(VideoCallError.invalidDataError)
//            }
            
        case .celebPaused:
//            print("Celeb paused")
            return .celebPaused
            
        case .celebLeft:
//            print("Celeb left")
            return .celebLeft
            
        case .celebShowEnd:
//            print("Show ended")
            return .celebLeft //TODO: - Ignore show calls
            
        case .winnerGetPass:
            do {
                let result: CallResponse<CallPassInfo> = try convertResponse(response: response)
                let info = result.result
                
                return .callPass(info)
                
            }
            catch {
                return .error(error)
            }
            
        case .winnerJoinNow:
            do {
                let result: CallJoinInfo = try convertResponse(response: response)
                return .callJoin(result)
            }
            catch {
                return .error(error)
            }
            
        case .winnerJoined:
            if let json = response as? [String: Any],
               var result = json["result"] as? [String: Any] {
                
                var eventID: Int = 0
                if let id = result["eventId"] as? String {
                    eventID = Int(id) ?? 0
                    result["eventId"] = eventID
                }
                else if let id = result["eventId"] as? Int {
                    eventID = id
                }
                
                if eventID == self.eventID {
                    do {
                        let info: CallJoinedInfo = try convertResponse(response: result)
                        return .winnerJoined(info)
                    }
                    catch {
                        return .error(error)
                    }
                }
                else {
                    return .error(VideoCallError.invalidDataError)
                }
            }
            else {
                return .error(VideoCallError.invalidDataError)
            }
                        
//            do {
//                let result: CallResponse<CallJoinedInfo> = try convertResponse(response: response)
//                let info = result.result
//
//                return .winnerJoined(info)
//            }
//            catch {
//                return .error(error)
//            }
                                                
        case .winnerLeft:
            return .winnerLeft
            
        case .eventStreamUpdate:
            print("⚠️ Stream update received. Require handing")
            return .streamUpdate
            
        case .viewerCount:
            do {
                let result: CallResponse<CallViewerCount> = try convertResponse(response: response)
                let info = result.result
                
                return .viewerCount(info)
            }
            catch {
                return .error(error)
            }
            
        case .eventComplete:
            do {
                let result: CallEventCompleteInfo = try convertResponse(response: response)
                return .callEnded(result)
            }
            catch {
                return .error(error)
            }
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
            print("response \(response)")
            throw VideoCallError.responseError
        }
    }
}


extension VideoCallSocketManager {
    func startCall() {
        //Only celebrity should start call
        guard userID == celebID
        else { return }
        
        let message = SocketEmitMessage(event: "celeb_start_call", data: nil)
        socket?.send(message)
        //print("Celebrity start call sent")
    }
    
    func joinCall() {
        //NOTE: - Call when the video call session is ready & socket is connected
        //For celebrity, send celeb_ready event
        //For user, send winner_joined event
        
        if userID == celebID {
            let message = SocketEmitMessage(event: "celeb_ready",
                                            data: ["celebStreamId": "\(celebID)"])
            socket?.send(message)
            //print("Celebrity ready message sent")
        }
        else {
            let message = SocketEmitMessage(event: "winner_joined",
                                            data: nil)
            socket?.send(message)
            //print("Winner joined message sent")
        }
    }
        
    func pauseCall() {
        guard userID == celebID
        else { return } //Send message from celebrity only
        
        let message = SocketEmitMessage(event: "celeb_pause", data: ["pause" : true])
        socket?.send(message)
        
//        stopTimer()
        
        //print("Celebrity pause call sent")
    }
    
    func resumeCall() {
        guard userID == celebID
        else { return } //Send message from celebrity only
        
        let message = SocketEmitMessage(event: "celeb_pause", data: ["pause" : false])
        socket?.send(message)
        
//        startTimer()
        //print("Celebrity resume call sent")
    }
    
    func leaveCall(didPause: Bool) {
        if userID == celebID {
            let message = SocketEmitMessage(event: "celeb_left", data: ["pause": didPause])
            socket?.send(message)
            //print("Celebrity left message sent")
//            socket?. //socketManager?.emitAll("celeb_left", ["pause": false])
        }
        else {
            let message = SocketEmitMessage(event: "winner_left", data: ["pause": didPause])
            socket?.send(message)
            //print("Winner left message sent")
        }
//        stopTimer()
    }
    
    func reportAbuse(user userID: Int) {
        let message = SocketEmitMessage(event: "report_abuse", data: ["winnerUserId": "\(userID)"])
        socket?.send(message)
        //print("Report abuse sent for user \(userID)")
    }
    
    func pingTimer() {
        let message = SocketEmitMessage(event: "timer_call", data: nil)
        socket?.send(message)
    }
}

