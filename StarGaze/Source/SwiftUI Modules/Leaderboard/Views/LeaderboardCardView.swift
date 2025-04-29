//
//  LeaderboardCardView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Combine
import Kingfisher

struct LeaderboardCardView: View {
    @ObservedObject var viewModel: LeaderboardViewModel    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                Text(viewModel.title)
                    .foregroundColor(.text1)
                    .font(.system(size: 20,
                                  weight: .bold))

                Spacer()

                Image("arrowRight2")
                    .tint(.text1)
                    .frame(width: 18,
                           height: 14)
            }
            .frame(height: 23)
            
            if let user = viewModel.users.first {
                HStack(alignment: .center) {
                    
                    HStack(alignment: .center,
                           spacing: 12) {
                        avatarView(user: user)
                            .frame(width: 48,
                                   height: 48)
                        
                        Text(user.name)
                            .foregroundColor(.text1)
                            .font(.system(size: 16,
                                          weight: .regular))
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .center,
                           spacing: 8) {
                        Image("likeFill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .aspectRatio(contentMode: .fit)
                        
                        Text(NSNumber(value: user.coins),
                             formatter: NumberFormatter.decimalFormatter)
                        .foregroundColor(.text1)
                        .font(.system(size: 16,
                                      weight: .regular))
                    }
                    
                }
                .padding(.leading, -4)
            }
        }
        .padding(27)
        .background(
            Color.profileInfoBackground
                .cornerRadius(15)
        )
    }
    
    private func avatarView(user: LeaderboardUser) -> some View {
        ZStack(alignment: .topTrailing) {
            Capsule(style: .circular)
                .fill(Color.white
                    .opacity(0.2))
            
            KFImage(user.picURL)
                .placeholder({
                    Image("profilePlaceholder")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40,
                               height: 40)
                })
                .setProcessor(
                    DownsamplingImageProcessor(size: CGSize(width: 40,
                                                            height: 40))
                )
                .cacheOriginalImage()
                .aspectRatio(contentMode: .fill)
                .clipShape(Capsule())
                .frame(width: 40,
                       height: 40)
                .offset(x: -4, y: 4)
                            
            Image("crown")
                .offset(x: 2, y: -10)
//                .frame(width: 26, height: 24)
        }
        
        
    }
    
}

//struct LeaderboardCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaderboardCardView(viewModel: .preview)
//            .preferredColorScheme(.dark)
//    }
//}
