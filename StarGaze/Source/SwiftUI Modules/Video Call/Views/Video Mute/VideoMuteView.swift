//
//  VideoMuteView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher

struct VideoMuteView: View {
    @State var avatarURL: URL?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                Spacer(minLength: 25)
                
                GeometryReader { proxy in
                    KFImage(avatarURL)
                        .resizable()
                        .placeholder({
                            Image("profilePlaceholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .preferredColorScheme(.dark)
                        })
                        .fade(duration: 0.25)
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: min(proxy.size.width, proxy.size.height),
                               height: min(proxy.size.width, proxy.size.height))
                    
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .stroke(.white, lineWidth: 2)
                        }
                }
                .frame(minWidth: 46, maxWidth: 136,
                       minHeight: 46, maxHeight: 136)
                .aspectRatio(1, contentMode: .fit)

                
                Spacer(minLength: 25)
            }
            
            Spacer()
        }
        .background(Color.darkText.ignoresSafeArea())
    }
}

struct VideoMuteView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing:0) {
//            Spacer()
            HStack(spacing:0) {
//                Spacer()
                VideoMuteView(avatarURL: nil)
//                    .frame(width: 95, height: 132)
                
//                Spacer()
            }
//            Spacer()
        }
        .background(Color.red.ignoresSafeArea())
    }
}
