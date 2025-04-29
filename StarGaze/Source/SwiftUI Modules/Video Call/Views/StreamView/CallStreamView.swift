//
//  CallStreamView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct CallStreamView: View {
    @ObservedObject var viewModel: CallStreamViewModel
    @State var alignment: VerticalAlignment
    
    var body: some View {
        ZStack {
            videoOverlayView()
            if viewModel.showMuteOverlay {
                audioOverlayView()
            }
        }
        .background(ClearBackgroundView())
    }
    
    @ViewBuilder
    private func videoOverlayView() -> some View {
        switch viewModel.videoState {
        case .unmute, .offline:
            EmptyView()
            
        case .mute:
            VideoMuteView(avatarURL: viewModel.avatarURL)
            
        case .congession:
            OverlayView(info: SGOverlayInfo(title: NSLocalizedString("video-call.network.poor.title", comment: ""),
                                                                    icon: "radio",
                                                                    message: NSLocalizedString("video-call.network.poor.msg", comment: "")))
            
        case .pause:
            OverlayView(info: SGOverlayInfo(title: NSLocalizedString("video-call.celeb.video.pause.title", comment: ""),
                                                                    icon: "videoPause",
                                                                    message: NSLocalizedString("video-call.celeb.video.pause.msg", comment: "")))
        }
    }
    
    @ViewBuilder
    private func audioOverlayView() -> some View {
        switch viewModel.audioState {
        case .unMute:
            EmptyView()
            
        case .mute:
            VStack(spacing: 0) {
                if alignment != .top {
                    Spacer()
                }
                
                HStack {
                    AudioMuteView(title: viewModel.userName, padding: EdgeInsets(top: 7, leading: 12, bottom: 8, trailing: 10))
                    Spacer()
                }
                .padding(20)
                
                if alignment != .bottom {
                    Spacer()
                }
            }
        }
    }
}

struct CallStreamView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CallStreamViewModel()
        viewModel.update(with: 0, name: "Suraj", avatarURL: nil)
        viewModel.updateState(.video(.pause))
        viewModel.updateState(.audio(.mute))
        
        return CallStreamView(viewModel: viewModel, alignment: .top)
            .background(Color.blue)
    }
}
