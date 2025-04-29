//
//  CallControlView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import CountryKit
import SwiftDate
struct CallControlView: View {
    @ObservedObject var remoteViewModel: CallStreamViewModel
    @ObservedObject var localViewModel: LocalStreamViewModel
    
    @State private var showAudioMuteOverlay: Bool = false
    @State private var showVideoMuteOverlay: Bool = false
    
    var body: some View {
        ZStack {
            videoOverlayView()
            
            VStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .top, spacing: 0) {
                        Button {
                            localViewModel.flagSubject.send()
                        } label: {
                            Image("videoFlag")
                                .resizable()
                                .frame(width: 58, height: 58)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text(remoteViewModel.userName)
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                        
                            Text(localViewModel.counterText + " left…")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("viewers.count"
                                .formattedString(value: localViewModel.viewCount))
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Color.black
                                    .opacity(0.4)
                                    .clipShape(Capsule())
                            )
                        }
                        .padding(.top, 12)
                        
                        
                        Spacer()
                        
                        Button {
                            localViewModel.cameraFlipSubject.send()
                        } label: {
                            Image("cameraSwap")
                                .resizable()
                                .frame(width: 58, height: 58)
                        }

                    }
                    
                    HStack(alignment: .center, spacing: 6) {
                        Image("handleIcon")
                        
                        Text("@" + remoteViewModel.userName)
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .medium))
                            .kerning(-0.33)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 2)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 16) {
                    if remoteViewModel.audioState == .mute {
                        AudioMuteView(title: remoteViewModel.userName,
                                      padding: EdgeInsets(top: 9, leading: 17, bottom: 9, trailing: 12))
                    }
                    HStack(alignment: .bottom, spacing: 28) {
                        Button {
                            localViewModel.didMuteAudio.toggle()
                            if localViewModel.didMuteAudio {
                                localViewModel.updateState(.audio(.mute))
                            }
                            else {
                                localViewModel.updateState(.audio(.unMute))
                            }
//                            if localViewModel.audioState == .mute {
//                                localViewModel.updateState(.audio(.unMute))
//                            }
//                            else {
//                                localViewModel.updateState(.audio(.mute))
//                            }
                            
                        } label: {
                            Image(localViewModel.audioState == .unMute ? "callAudioMute" : "callAudioMuted")
                                .resizable()
                                .frame(width: 58, height: 58)
                        }
                        
                        Button {
                            localViewModel.callCloseSubject.send()
                        } label: {
                            Image("callDisconnect")
                                .resizable()
                                .frame(width: 74, height: 74)
                        }
                                        
                        Button {
                            localViewModel.didMuteVideo.toggle()
                            if localViewModel.didMuteVideo {
                                localViewModel.updateState(.video(.mute))
                            }
                            else {
                                localViewModel.updateState(.video(.unmute))
                            }
//                            if localViewModel.videoState == .mute {
//                                localViewModel.updateState(.video(.unmute))
//                            }
//                            else {
//                                localViewModel.updateState(.video(.mute))
//                            }
                        } label: {
                            Image(localViewModel.videoState == .mute ? "callVideoMuted" : "callVideoMute")
                                .resizable()
                                .frame(width: 58, height: 58)
                        }
                    }
                    .padding(.bottom,
                             ((UIApplication.shared
                                .delegate?.window??
                                .safeAreaInsets)?.bottom ?? 0) > 0
                             ? 0
                             : 10)
                }
                .frame(maxWidth: .greatestFiniteMagnitude)
                
                
            }
            .background(.clear)
            
            if showAudioMuteOverlay {
                CallToastView(title: NSLocalizedString("video-call.audio.mute.overlay.title", comment: ""),
                              icon: "audioMuteToastIcon")
                .transition(.scale.combined(with: .opacity))
            }
            if showVideoMuteOverlay {
                CallToastView(title: NSLocalizedString("video-call.video.mute.overlay.title", comment: ""),
                              icon: "videoMuteToastIcon")
                .transition(.scale.combined(with: .opacity))
            }
        }
        .background(ClearBackgroundView())
        .onReceive(localViewModel.$didMuteVideo) { output in
            if output == true {
                withAnimation(.easeIn) {
                    self.showVideoMuteOverlay = true
                }
                
                DispatchQueue.main
                    .asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.showVideoMuteOverlay = false
                        }
                }
            }
            else {
                withoutAnimation {
                    self.showVideoMuteOverlay = false
                }
            }
        }
        .onReceive(localViewModel.$didMuteAudio) { output in
            if output == true {
                withAnimation(.easeIn) {
                    self.showAudioMuteOverlay = true
                }
                
                DispatchQueue.main
                    .asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.showAudioMuteOverlay = false
                        }
                }
            }
            else {
                withoutAnimation {
                    self.showAudioMuteOverlay = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func videoOverlayView() -> some View {
        switch remoteViewModel.videoState {
        case .unmute:
            EmptyView()
            
        case .mute:
            VideoMuteView(avatarURL: remoteViewModel.avatarURL)
            
        case .offline, .congession:
            OverlayView(info: SGOverlayInfo(title: NSLocalizedString("video-call.network.poor.title", comment: ""),
                                                                    icon: "radio",
                                                                    message: NSLocalizedString("video-call.network.poor.msg", comment: "")))
            
        case .pause:
            OverlayView(info: SGOverlayInfo(title: NSLocalizedString("video-call.celeb.video.pause.title", comment: ""),
                                                                    icon: "videoPause",
                                                                    message: NSLocalizedString("video-call.celeb.video.pause.msg", comment: "")))
        }
    }
}

struct CallControlView_Previews: PreviewProvider {
    static var viewModel = CallStreamViewModel()
    static var localViewModel = LocalStreamViewModel()
    
    static var previews: some View {
        viewModel.update(with: 0, name: "Suraj", avatarURL: nil)
        viewModel.updateState(.audio(.mute))
        viewModel.updateState(.video(.offline))
        
        localViewModel.viewCount = 1
        localViewModel.duration = 130
        
        return CallControlView(remoteViewModel: CallControlView_Previews.viewModel,
                        localViewModel: CallControlView_Previews.localViewModel)
        .background(Color.black)
    }
}
