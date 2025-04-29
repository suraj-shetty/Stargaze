//
//  PlayerView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import AVKit
import CountryKit
import YPImagePicker
import Player

//import GSPlayer

enum SGPlayerState {
    case none
    case buffering
    case playing
    case paused
    case error(NSError)
}

extension SGPlayerState: Equatable {
    
    public static func == (lhs: SGPlayerState, rhs: SGPlayerState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.buffering, .buffering):
            return true
        case (.playing, .playing):
            return true
        case (.paused, .paused):
            return true
        case let (.error(e1), .error(e2)):
            return e1 == e2
        default:
            return false
        }
    }
    
}



//struct SGVideoPlayer: UIViewRepresentable {
//
//    var url:URL
//    var contentMode: UIView.ContentMode = .scaleAspectFill
//    @Binding var isPlaying:Bool
//    @Binding var isMuted: Bool
//    @Binding var state: SGPlayerState
//
//    var timeUpdateCallback: ((TimeInterval, TimeInterval) -> ())? = nil
//
//    typealias UIViewType = VideoPlayerView
//
//    func makeCoordinator() -> PlayerCoordinator {
//        return PlayerCoordinator(player: self)
//    }
//
//
//    func makeUIView(context: Context) -> VideoPlayerView {
//        let playerView = VideoPlayerView()
//        playerView.isMuted = isMuted
//        playerView.contentMode = contentMode
//        playerView.load(for: url, shouldPlay: false)
//
//        context.coordinator.bindTo(videoView: playerView)
//
//        return playerView
//    }
//
//    func updateUIView(_ uiView: VideoPlayerView, context: Context) {
//        uiView.isMuted = isMuted
////        print("SGVideoPlayer play state \(isPlaying)")
//        if isPlaying {
//            uiView.resume()
//        }
//        else {
//            uiView.pause(reason: .userInteraction)
//        }
//
//    }
//
//    static func dismantleUIView(_ uiView: VideoPlayerView, coordinator: PlayerCoordinator) {
//        uiView.isMuted = true
//        uiView.pause()
//        coordinator.unbind()
//
////        self.timeUpdateCallback = nil
//
//        print("SGVideoPlayer dismantled")
//    }
//
//
//    class PlayerCoordinator: NSObject {
//        let parent: SGVideoPlayer
//        var timeObserver: Any?
//        var playerView: VideoPlayerView?
//
//        init(player: SGVideoPlayer) {
//            self.parent = player
//        }
//
//        func bindTo(videoView: VideoPlayerView) {
//            if let playerView = playerView, let timeObserver = timeObserver {
//                playerView.removeTimeObserver(timeObserver)
//            }
//
//            self.playerView = videoView
//
//            videoView.stateDidChanged = { playerState in
//
//                DispatchQueue.main.async { [weak self] in
//                    print("\(self?.playerView?.playerURL?.absoluteString ?? "")")
//                    print("State \(playerState)")
//
//                    switch playerState {
//                    case .none:
//                        self?.parent.state = .none
//
//                    case .loading:
//                        self?.parent.state = .buffering
//
//                    case .error(let error):
//                        self?.parent.state = .error(error)
//
//                    case .playing:
//                        self?.parent.state = .playing
//
//                    case .paused(_, _):
//                        if self?.playerView?.pausedReason == .waitingKeepUp {
//                            self?.parent.state = .buffering
//                        }
//                        else {
//                            self?.parent.state = .paused
//                        }
//                    }
//                }
//
//            }
//
//            self.timeObserver =  videoView.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1,
//                                                                                       preferredTimescale: 60)) {[weak self] _ in
//                guard let ref = self else { return }
//
//                let currentTime = videoView.currentDuration
//                let totalTime   = videoView.totalDuration
//
//                ref.parent.timeUpdateCallback?(currentTime, totalTime)
//            }
//        }
//
//        func unbind() {
//            if let playerView = playerView, let timeObserver = timeObserver {
//                playerView.removeTimeObserver(timeObserver)
//            }
//        }
//    }
//}


struct SGVideoPlayer: UIViewControllerRepresentable {
    
    var url:URL
    var contentMode: UIView.ContentMode = .scaleAspectFill
    @Binding var isPlaying:Bool
    @Binding var isMuted: Bool
    @Binding var state: SGPlayerState
    
    var timeUpdateCallback: ((TimeInterval, TimeInterval) -> ())? = nil
    
//    typealias UIViewType = VideoPlayerView
    typealias UIViewControllerType = Player
    
    func makeCoordinator() -> PlayerCoordinator {
        return PlayerCoordinator(player: self)
    }
    
    func makeUIViewController(context: Context) -> Player {
        let player = Player()
        player.playerDelegate = context.coordinator
        player.playbackDelegate = context.coordinator
        player.muted = isMuted
        player.playbackLoops = true
        player.autoplay = true
        player.url = url
        
        switch contentMode {
        case .scaleToFill:
            player.fillMode = .resize
        case .scaleAspectFit:
            player.fillMode = .resizeAspect
        case .scaleAspectFill:
            player.fillMode = .resizeAspectFill
        default:
            player.fillMode = .resizeAspectFill
        }
        return player
    }
    
    func updateUIViewController(_ uiViewController: Player, context: Context) {
        uiViewController.muted = isMuted
        if isPlaying {
            uiViewController.playFromCurrentTime()
        }
        else {
            uiViewController.pause()
        }
        
//        if let parent = uiViewController.playerView.superview {
//            uiViewController.playerView.frame = parent.bounds
//        }
    }
    
    static func dismantleUIViewController(_ uiViewController: Player, coordinator: PlayerCoordinator) {
        uiViewController.muted = true
        uiViewController.pause()
     
        print("SGVideoPlayer dismantled")
    }
    
//    static func dismantleUIView(_ uiView: VideoPlayerView, coordinator: PlayerCoordinator) {
//        uiView.isMuted = true
//        uiView.pause()
//        coordinator.unbind()
//
////        self.timeUpdateCallback = nil
//
//        print("SGVideoPlayer dismantled")
//    }
    
        
    class PlayerCoordinator: NSObject, PlayerPlaybackDelegate, PlayerDelegate {
        let parent: SGVideoPlayer
        var timeObserver: Any?
        var player: Player?
        
        init(player: SGVideoPlayer) {
            self.parent = player
        }
        
        //        func bindTo(videoView: VideoPlayerView) {
        //            if let playerView = playerView, let timeObserver = timeObserver {
        //                playerView.removeTimeObserver(timeObserver)
        //            }
        //
        //            self.playerView = videoView
        //
        //            videoView.stateDidChanged = { playerState in
        //
        //                DispatchQueue.main.async { [weak self] in
        //                    print("\(self?.playerView?.playerURL?.absoluteString ?? "")")
        //                    print("State \(playerState)")
        //
        //                    switch playerState {
        //                    case .none:
        //                        self?.parent.state = .none
        //
        //                    case .loading:
        //                        self?.parent.state = .buffering
        //
        //                    case .error(let error):
        //                        self?.parent.state = .error(error)
        //
        //                    case .playing:
        //                        self?.parent.state = .playing
        //
        //                    case .paused(_, _):
        //                        if self?.playerView?.pausedReason == .waitingKeepUp {
        //                            self?.parent.state = .buffering
        //                        }
        //                        else {
        //                            self?.parent.state = .paused
        //                        }
        //                    }
        //                }
        //
        //            }
        //
        //            self.timeObserver =  videoView.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1,
        //                                                                                       preferredTimescale: 60)) {[weak self] _ in
        //                guard let ref = self else { return }
        //
        //                let currentTime = videoView.currentDuration
        //                let totalTime   = videoView.totalDuration
        //
        //                ref.parent.timeUpdateCallback?(currentTime, totalTime)
        //            }
        //        }
        //
        //        func unbind() {
        //            if let playerView = playerView, let timeObserver = timeObserver {
        //                playerView.removeTimeObserver(timeObserver)
        //            }
        //        }
        
    //MARK: - PlayerDelegate
        func playerReady(_ player: Player) {
//            player.playFromCurrentTime()
            self.parent.state = .playing
        }
        
        func playerBufferTimeDidChange(_ bufferTime: Double) {
            
        }
        
        func player(_ player: Player, didFailWithError error: Error?) {
            if let error = error as? NSError {
                parent.state = .error(error)
            }
            else {
                parent.state = .error(PlayerError.failed as NSError)
            }
        }
        
        func playerPlaybackStateDidChange(_ player: Player) {
            let state = player.playbackState
            switch state {
            case .stopped:  parent.state = .paused
            case .paused:   parent.state = .paused
            case .failed:   parent.state = .error(PlayerError.failed as NSError)
            case .playing:  parent.state = .playing
            }
        }
        
        func playerBufferingStateDidChange(_ player: Player) {
            let state = player.bufferingState
            switch state {
            case .unknown:  parent.state = .buffering
            case .delayed:  parent.state = .buffering
            case .ready:    parent.state = .playing
            }
        }
        
        //MARK: - PlayerPlaybackDelegate
        func playerCurrentTimeDidChange(_ player: Player) {
            let currentTime = player.currentTimeInterval
            let duration = player.maximumDuration
            
            parent.timeUpdateCallback?(currentTime, duration)
        }
        
        func playerPlaybackDidEnd(_ player: Player) {
            
        }
        
        func playerPlaybackDidLoop(_ player: Player) {
            
        }
        
        func playerPlaybackWillLoop(_ player: Player) {
            
        }
        
        func playerPlaybackWillStartFromBeginning(_ player: Player) {
            
        }
        
    }
}



struct PlayerView: View {
    let url: URL
    @State private var isPlaying:Bool = false
    
    @State private var muted: Bool = false
    @State private var isVisible:Bool = false
    
    @State private var playerState: SGPlayerState = .buffering
    @EnvironmentObject var viewState: ViewState
    
    @State var contentMode: UIView.ContentMode = .scaleAspectFill
    
    var body: some View {

        SGVideoPlayer(url: url,
                      contentMode: contentMode,
                      isPlaying: $isPlaying,
                      isMuted: $muted,
                      state: $playerState)
            .onAppear() {
                isVisible = true
            }
            .onDisappear() {
                isVisible = false
            }
            .onChange(of: viewState.isVisible) { newValue in
    //            print("Parent view state changed \(newValue)")
                self.updatePlayState()
            }
            .onChange(of: isVisible) { newValue in
    //            print("Video card can Play \(newValue)")
                self.updatePlayState()
            }
    }
    
    private func updatePlayState() {
        self.isPlaying = isVisible && viewState.isVisible
    }
}

struct AttachmentPlayerView: View {
    let attachment: SGCreateFeedAttachment
    @State private var isPlaying:Bool = false
    
    @State private var muted: Bool = false
    @State private var isVisible:Bool = false
    
    @State private var playerState: SGPlayerState = .buffering
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {

        if let url = attachment.fileURL {
            SGVideoPlayer(url: url,
                          isPlaying: $isPlaying,
                          isMuted: $muted,
                          state: $playerState)
                .onAppear() {
                    isVisible = true
                }
                .onDisappear() {
                    isVisible = false
                }
                .onChange(of: viewState.isVisible) { _ in
        //            print("Parent view state changed \(newValue)")
                    self.updatePlayState()
                }
                .onChange(of: isVisible) { _ in
        //            print("Video card can Play \(newValue)")
                    self.updatePlayState()
                }
                .onReceive(attachment.$canPlay, perform: { _ in
                    self.updatePlayState()
                })
        }
        else {
            EmptyView()
        }
    }
    
    private func updatePlayState() {
        self.isPlaying = isVisible && viewState.isVisible && attachment.canPlay
    }
}


struct RemotePlayerView: View {
    @ObservedObject var media: SGMediaViewModel
    var backgroundColor: Color = .mediaPlaceholder
    
    @State var contentMode: UIView.ContentMode = .scaleAspectFill
    
    @EnvironmentObject var viewState: ViewState
    
    @State private var isVisible:Bool = false
    @State private var playVideo:Bool = false
    @State private var muted: Bool = false
    
    @State private var timeLeft: TimeInterval = 0
    @State private var playerState: SGPlayerState = .none
    
    var timeUpdateCallback: ((TimeInterval, TimeInterval) -> ())? = nil
    
    var body: some View {
        
        ZStack {
            SGVideoPlayer(url: media.url!,
                          contentMode: contentMode,
                          isPlaying: $playVideo,
                          isMuted: $muted,
                          state: $playerState) { (currentTime, totalTime) in
                self.timeLeft = totalTime - currentTime
                self.timeUpdateCallback?(currentTime, totalTime)
            }
            
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Text(NSNumber(value: timeLeft),
                         formatter: DurationFormatter())
                    .foregroundColor(.white)
                    .font(.system(size: 12,
                                  weight: .regular))
                    .padding(.horizontal, 7)
                    .frame(height: 18)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.black.opacity(0.35))
                    )
                    
                    Spacer()
                    
                    Image(muted ? "mute" : "unmute")
                        .frame(width: 39, height: 39)
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded({ _ in
                                    AppState.shared.videoMuted.toggle()
                                })
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
            }
            
            if playerState == .buffering {
                ZStack(alignment: .center) {
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(.circular)
                }
                .background(
                    Color.black.opacity(0.4)
                )
            }
        }
        .background(
            placeholderView()
        )
        .onAppear() {
            isVisible = true
            muted = AppState.shared.videoMuted
        }
        .onDisappear() {
            isVisible = false
        }
        .onChange(of: media.playMedia) { newValue in
            self.updatePlayState()
        }
        .onChange(of: isVisible) { newValue in
//            print("Video card can Play \(newValue)")
            self.updatePlayState()
        }
        .onChange(of: viewState.isVisible) { newValue in
//            print("Parent view state changed \(newValue)")
            self.updatePlayState()
        }
        .onReceive(AppState.shared.$videoMuted) { isMuted in
            self.muted = isMuted
        }
        .onChange(of: playerState) { newValue in
            debugPrint("Player State \(playerState)")
        }
    }
    
    private func updatePlayState() {
//        print("***********")
//        print("updatePlayState")
//        print("Player vissible \(isVisible)")
//        print("Plarent visible \(viewState.isVisible)")
//        print("Can play \(media.playMedia)")
//        print("***********")
        self.playVideo = isVisible && viewState.isVisible && media.playMedia
    }
    
    @ViewBuilder
    private func placeholderView() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 14) {
                Spacer()
                
                Image("videoPlaceHolder")
                Text("video.loading.placeholder".localizedKey)
                    .font(.system(size: 12, weight: .medium))
                    .kerning(5)
                    .foregroundColor(.mediaTextPlaceholder)
                    .opacity(0.26)
                
                Spacer()
            }
            Spacer()
        }
            .background(backgroundColor)
    }
}

struct ExclusiveVideoPlayer: View {
    @ObservedObject var media: SGMediaViewModel
    @Binding var showSubscription: Bool
    
    @State private var showOverlay: Bool = false
    
    var body: some View {
        RemotePlayerView(media: media) { (currentTime, _) in
            if currentTime >= 3 {
                self.media.playMedia = false
                self.showOverlay = true
            }
        }
        .overlay(content: {
            ZStack(alignment: .center) {
                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                
                Button {
                    self.showSubscription = true
                } label: {
                    Text("feed.card.subscribe".localizedKey)
                        .foregroundColor(.white)
                        .underline()
                        .fontWithLineHeight(font: .systemFont(ofSize: 16,
                                                              weight: .regular),
                                            lineHeight: 21)
                        .frame(width: 268.0)
                        .multilineTextAlignment(.center)
                }
            }
            .opacity(showOverlay ? 1 : 0)
        })
    }
}

class DurationFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let number = obj as? NSNumber
        else {
            return nil
        }
        
        let timeInterval    = Int(number.doubleValue)
        let minutes         = timeInterval / 60
        let seconds         = timeInterval % 60
        let time            = String(format: "%01d:%02d", minutes, seconds)
        return time
    }
}

