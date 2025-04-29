//
//  LeaderboardRankView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 29/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher

struct LeaderboardRankView: View {
    var users:[LeaderboardUser]!
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack(alignment: .center) {
                rankView(for: 3)
                
                Spacer()
                
                rankView(for: 2)
            }
            .offset(x: 0, y: 17)

            firstRankView()
        }
        
    }
    
    private func firstRankView() -> some View {
        guard let firstRankUser = users?.first(where: { $0.rank == 1 })
        else {
            return AnyView(
                Color.clear
                    .frame(width: 174, height: 168)
            )
        }
        
        return AnyView (
            ZStack(alignment: .bottom) {
                avatarView(user: firstRankUser)
                    .offset(x: 0, y: -4)
                Image("winner")
                    .resizable()
                    .offset(x: 6, y: 0)
            }
            .frame(width: 174, height: 168)
        )
    }
    
    private func rankView(for rank:Int) -> some View {
        guard let user = users?.first(where: { $0.rank == rank })
        else {
            return AnyView(
                Color.clear
                    .frame(width: 70)
            )
        }
        
        return AnyView (
            ZStack(alignment: .bottom) {
                avatarView(user: user)
            }
        )
    }
    
    private func avatarView(user: LeaderboardUser) -> some View {
        let isFirst         = (user.rank == 1)
        let imageLength     = isFirst ? 108.0 : 70.0
        let rankBorderWidth = isFirst ? 3.0 : 2.0
        let rankLength      = isFirst ? 32.0 : 22.0
        
        return ZStack(alignment: .bottom) {
            KFImage(user.picURL)
                .placeholder({
                    Image("profilePlaceholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageLength,
                               height: imageLength)
                })
                .setProcessor(
                    DownsamplingImageProcessor(size: CGSize(width: imageLength,
                                                            height: imageLength))
                )
                .cacheOriginalImage()
                .aspectRatio(contentMode: .fill)
                .clipShape(Capsule())
                .frame(width: imageLength,
                       height: imageLength)
                .overlay(
                    Capsule()
                        .stroke(Color.rankColor(for: user.rank),
                                lineWidth: 2)
                )
                .padding(.bottom, rankLength/2.0)
                
            Text(user.rank.localeFormatted())
                .font(.system(size: isFirst ? 18.0 : 13.0,
                              weight: .medium))
                .foregroundColor(.darkText)
                .frame(width: rankLength,
                   height: rankLength)
                .background(
                    Color.rankColor(for: user.rank)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.profileInfoBackground,
                                lineWidth: rankBorderWidth)
                )
        }
    }
}

//struct LeaderboardRankView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaderboardRankView(users: LeaderboardUser.list)
//            .background(Color.profileInfoBackground)
//            .padding(.horizontal, 0)
////            .preferredColorScheme(.dark)
//    }
//}
