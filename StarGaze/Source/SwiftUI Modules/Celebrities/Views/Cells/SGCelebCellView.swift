//
//  SGCelebCellView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 19/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
import KMBFormatter
import ToastUI

struct SGCelebCellView: View {
    @ObservedObject var viewModel: SGCelebrityViewModel
    @Environment(\.redactionReasons) var redactionReasons
    
    var body: some View {
        HStack(alignment: .center,
               spacing: 12) {
            KFImage(viewModel.picURL)
                .resizable()
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .scaleFactor(UIScreen.main.scale)
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 56,
                                                                      height: 56))
                )
                .cacheOriginalImage()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .background(Color.text1.opacity(0.2))
                .clipShape(Capsule())
            
            VStack(alignment:.leading, spacing:0) {
                Spacer()
                Text(viewModel.name)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.text2)
                    .frame(height:24)                             
                
                Text(viewModel.followersCountText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.text2)
                    .frame(height:14)
                    .opacity(0.5)
                
                Spacer()
            }
            
            Spacer()
            
            if !viewModel.isMyProfile {
                if viewModel.isFollowed {
                    Button {
                        viewModel.toggleFollow()
                    } label: {
                        
                        Text("Unfollow")
                            .foregroundColor(.celebBrand)
                            .font(.system(size: 13, weight: .medium))
                            .kerning(-0.08)
                            .frame(height: 18)
                            .padding(EdgeInsets.init(top: 6, leading: 22, bottom: 5, trailing: 22))
                    }
                    .background(Capsule()
                        .stroke(Color.brand2, lineWidth: 1))
                    .buttonStyle(.plain)
                }
                else {
                    Button {
                        viewModel.toggleFollow()
                    } label: {
                        Text("Follow")
                            .foregroundColor(.darkText)
                            .font(.system(size: 13, weight: .medium))
                            .kerning(-0.08)
                            .frame(height: 18)
                            .padding(EdgeInsets.init(top: 6, leading: 22, bottom: 5, trailing: 22))
                    }
                    .background(Capsule()
                        .fill(redactionReasons.contains(.placeholder)
                              ? Color.gray
                              : Color.celebBrand))
                    .buttonStyle(.plain)
                        
                }
            }
        }
               .buttonStyle(.borderless) //Made it borderless so that the inside button tap doesn't overlap with the whole view's tap gesture
               .toast(item: $viewModel.error) { error in
                   VStack {
                       SGErrorToastView(message: (self.viewModel.error ?? SGAPIError.invalidBody).localizedDescription)
                           .frame(maxHeight: 130)
                           .padding(.horizontal, 20)
                       Spacer()
                   }
               }
    }
}

//struct SGCelebCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        SGCelebCellView(viewModel: .preview)
//            .previewLayout(.fixed(width: 375, height: 56))
//            .preferredColorScheme(.dark)
//    }
//}
