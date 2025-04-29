//
//  DailyRewardCellView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 09/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct DailyRewardCellView: View {
    var reward: DailyReward
    var body: some View {
        HStack(alignment: .center,
               spacing: 12) {
            Image(reward.type.iconName)
                .tint(.text1)
            
            Text(reward.type.title)
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
                .fixedSize(horizontal: false, vertical: false)
            
            Spacer()
            
            HStack(alignment: .center,
                   spacing: 6) {
                Image("silverCoin")
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("\(reward.coins)")
                    .foregroundColor(.text1)
                    .font(.system(size: 18,
                                  weight: .medium))
            }
        }
    }
}

struct DailyRewardCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DailyRewardCellView(reward: .init(type: .comment, coins: 20))
            
            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}
