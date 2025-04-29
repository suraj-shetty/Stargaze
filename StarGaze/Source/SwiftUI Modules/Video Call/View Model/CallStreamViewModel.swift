//
//  CallStreamViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

enum CallVideoState: Int {
    case mute = 0
    case unmute
    case congession
    case offline
    case pause
}

enum CallAudioState: Int {
    case mute = 0
    case unMute
//    case congession
}

enum CallStreamUpdate {
    case audio(CallAudioState)
    case video(CallVideoState)
    case networkCongession
    case pause
    case none
}


class CallStreamViewModel: ObservableObject {
    var userId: UInt = 0
    var userName: String = ""
    var avatarURL: URL? = nil
    
    @Published var audioState: CallAudioState = .unMute
    @Published var videoState: CallVideoState = .unmute
    @Published var showMuteOverlay: Bool = true
    
    func update(with uid: UInt, name: String, avatarURL:URL?) {
        self.userId = uid
        self.userName = name
        self.avatarURL = avatarURL
        
        self.objectWillChange.send()
    }
    
    func updateState(_ state: CallStreamUpdate) {
        switch state {
        case .audio(let callAudioState):
            self.audioState = callAudioState
                        
        case .video(let callVideoState):
            self.videoState = callVideoState
            
        case .networkCongession:
            self.videoState = .congession
            
        case .pause:
            self.videoState = .pause
            
        case .none:
            self.videoState = .unmute
            self.audioState = .unMute
        }
    }
    
    func reset() {
        self.audioState = .unMute
        self.videoState = .unmute
    }
}

class LocalStreamViewModel: CallStreamViewModel {
    @Published var duration:TimeInterval = 0
    @Published var viewCount: Int = 0
    @Published var didMuteAudio: Bool = false
    @Published var didMuteVideo: Bool = false
    
    let flagSubject = PassthroughSubject<Void, Never>()
    let cameraFlipSubject = PassthroughSubject<Void, Never>()
    let callCloseSubject = PassthroughSubject<Void, Never>()
    
    var counterText: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        let text = "\(minutes)m \(seconds)s"
        return text
    }
}
