//
//  DailyRewardListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 09/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct DailyRewardListView: View {
    var list:DailyRewardListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    
                    Text("blocked-list.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image("navClose")
                            .tint(Color.text1)
                    }
                    .frame(width: 49, height: 49)
                }
            }
            
            List {
                Image("collectCoinWin")
                    .padding(.horizontal, 44)
                    .listRowBackground(Color.brand1)
                    .listSectionSeparator(.hidden)
                
                ForEach(list.rewards, id:\.type) { reward in
                    VStack(spacing: 20, content: {
                        DailyRewardCellView(reward: reward)
                        
                        Divider()
                            .tint(.tableSeparator)
                    })
                        .listRowBackground(Color.brand1)
                        .listRowInsets(.init(top: 20,
                                             leading: 20,
                                             bottom: 0,
                                             trailing: 20))
                        .listRowSeparator(.hidden)
                        
                }
            }
            .listStyle(.plain)
            .padding(.bottom, 10)
            
            SGRoundRectButton(title: "COLLECT ALL") {
                dismiss()
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
    }
}

struct DailyRewardListView_Previews: PreviewProvider {
    static var previews: some View {
        DailyRewardListView(list: DailyRewardListViewModel(rewards: [DailyReward(type: .comment, coins: 10),
                                                                        DailyReward(type: .comment, coins: 10)]))
    }
}
