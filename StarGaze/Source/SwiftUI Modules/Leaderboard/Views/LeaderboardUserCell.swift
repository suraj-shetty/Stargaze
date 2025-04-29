//
//  LeaderboardUserCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 29/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher

struct LeaderboardUserCell: View {
    var user: LeaderboardUser!
    
    var body: some View {
        HStack(alignment: .center,
               spacing: 5) {
            avatarView()
            infoView()
            
            Spacer()
            
            ZStack(alignment: .center) {
                Image("rankStar")
            }
            .frame(width: 28,
                   height: 28)
            .background(
                (
                    user.isMe
                    ? Color.white
                        .opacity(0.4)
                    : Color.black
                        .opacity(0.14)
                )
            )
            .clipShape(Capsule())
            
            scoreText()
        }
               .padding(.horizontal, 15)
               .padding(.vertical, 9)
               .background(
                backgroundView()
               )
    }
    
    private func avatarView() -> some View {
        ZStack(alignment: .center) {
            KFImage(user.picURL)
                .placeholder({
                    Image("profilePlaceholder")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44,
                               height: 44)
                })
                .setProcessor(
                    DownsamplingImageProcessor(size: CGSize(width: 44,
                                                            height: 44))
                )
                .cacheOriginalImage()
                .aspectRatio(contentMode: .fill)
                .clipShape(Capsule())
                .frame(width: 44,
                       height: 44)
        }
        .frame(width: 52,
               height: 52)
        .background(
            Color.white.opacity(0.26)
        )
        .clipShape(Capsule())
        
        
    }
    
    private func infoView() -> some View {
        VStack(alignment: .leading,
               spacing: -1) {
            Text(user.isMe
                 ? NSLocalizedString("leaderboard.me.title", comment: "")
                 : user.name)
                .font(.system(size: 16,
                              weight: .regular))
                .foregroundColor( textColor() )
                .frame(height: 24)
        }
    }
    
    private func scoreText() -> some View {
        Text(NSNumber(value: user.coins),
             formatter: NumberFormatter.decimalFormatter)
        .font(.system(size: 16,
                      weight: .medium))
        .foregroundColor( textColor() )
        .frame(height: 22)
    }
    
    private func backgroundView() -> some View {
        if user.rank < 4 {
            return AnyView(
                Color.rankColor(for: user.rank)
                    .cornerRadius(11)
                    .shadow(color: Color.rankColor(for: user.rank)
                        .opacity(0.44),
                            radius: 11,
                            x: 0,
                            y: 2)
            )
        }
        else if user.isMe {
            return AnyView(
                Color.rankColor(for: 1)
                    .cornerRadius(11)
                    .shadow(color: Color.rankColor(for: 1)
                        .opacity(0.44),
                            radius: 11,
                            x: 0,
                            y: 2)
            )
        }
        else {
            return AnyView(
                Color.rankColor(for: user.rank)
                    .cornerRadius(11)
            )
        }
    }
    
    private func textColor() -> Color {
        if user.isMe {
            return .white
        }
        else if user.rank < 4 {
            return .darkText
        }
        else {
            return .text1
        }
    }
}

//struct LeaderboardUserCell_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaderboardUserCell(user: .preview)
//            .padding(.horizontal, 20)
////            .preferredColorScheme(.dark)
//    }
//}
