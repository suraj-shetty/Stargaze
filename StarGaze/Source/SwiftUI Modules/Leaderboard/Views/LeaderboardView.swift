//
//  LeaderboardView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 26/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Shimmer
import Introspect

struct LeaderboardView: View {
    @State private var current: LeaderboardOption = .allTime
    @State private var pickedIndex: Int = 0
    @State private var listHeight: CGFloat = 0
    
    @StateObject var viewModel = LeaderboardPageViewModel(types: [
        .allTime,
        .today,
        .month
    ])
        
    var body: some View {
        NavigationView {
            VStack(spacing:0) {
                HStack(alignment: .center) {
                    Button {
                        SideMenuViewModel.shared
                            .showMenu
                            .toggle()
                    } label: {
                        Image("navBack")
                            .tint(.text1)
                            .frame(minWidth: 49,
                                   maxHeight: 44)
                    }

                    Spacer()
                    
                    Text("leaderboard.title".localizedKey)
                        .foregroundColor(.text1)
                        .font(.system(size: 18,
                                      weight: .medium))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 49) //To center align the title
                    
                }
                .frame(height: 44)
                .background(
                    Color.brand1
                )
                
                let segments = viewModel.types.map({
                    SGSegmentItemViewModel(title: $0.title)
                })
                SegmentedPicker(index: $pickedIndex,
                                segments: segments)
                .frame(height: 34)
                .padding(EdgeInsets(top: 16,
                                    leading: 20,
                                    bottom: 22,
                                    trailing: 20))
                        
                List {
                    let viewModel = viewModel.viewModels[pickedIndex]
                    
                    if viewModel.list.isEmpty {
                        if viewModel.didEnd {
                            noLeaderboardPlaceholder()
                        }
                        else if viewModel.isLoading {
                            ForEach(0..<4) { _ in
                                cardView(for: .preview)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                                    .disabled(true) //To disable the navigtion link
                            }
                        }
                    }
                    else {
                        ForEach (viewModel.list) { category in
                            cardView(for: category)
                        }
                        
                        if viewModel.didEnd == false {
                            Text("Fetching More…")
                                .foregroundColor(.text1)
                                .font(.walsheimRegular(size: 12))
                                .opacity(0.5)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                                .onAppear {
                                    viewModel.fetchList(refresh: false)
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .background(
                    Color.brand1
                        .readSize(onChange: { size in
                            if size.height != listHeight {
                                listHeight = size.height
                            }
                        })
                )
            }
            .hiddenNavigationBarStyle() //To hide the navigation bars
            .background(
                Color.brand1
            )
            .onAppear {
                let viewModel = viewModel.viewModels[pickedIndex]
                if viewModel.list.isEmpty, viewModel.isLoading == false, viewModel.didEnd == false {
                    viewModel.fetchList(refresh: true)
                }
            }
            .onChange(of: pickedIndex) { index in
                let viewModel = viewModel.viewModels[index]
                if viewModel.list.isEmpty, viewModel.isLoading == false, viewModel.didEnd == false {
                    viewModel.fetchList(refresh: true)
                }
            }
        }
    }
    
    private func placeholderView(with image:String,
                                 title:LocalizedStringKey,
                                 message:LocalizedStringKey) -> some View {
        VStack(alignment: .center,
               spacing: 30) {
            Spacer()
            
            Image(image)
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .center,
                   spacing: 10) {
                Text(title)
                    .foregroundColor(.text1)
                    .font(.system(size: 22, weight: .medium))
                    .frame(height:25)
                
                Text(message)
                    .foregroundColor(.text1)
                    .font(.system(size: 16, weight: .regular))
                    .lineSpacing(6)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
               .listRowInsets(.init())
               .listRowBackground(Color.brand1)
               .listRowSeparator(.hidden)
               .frame(maxWidth:.infinity,
                      minHeight:self.listHeight,
                      maxHeight:self.listHeight)
    }
    
    private func noLeaderboardPlaceholder() -> some View {
        placeholderView(with: "noFeed",
                        title: "leaderboard.empty".localizedKey,
                        message: "NO_FEED_DESC".localizedKey)
    }
    
    private func cardView(for viewModel: LeaderboardViewModel) -> some View {
        return ZStack { //Added a ZStack to show the card view, without the navigation disclosure(cell accesory)
            LeaderboardCardView(viewModel: viewModel)
            
            NavigationLink {
                LeaderboardUserListView(viewModel: viewModel)
            } label: {
                EmptyView()
            }
        }
        .listRowInsets(.init(top: 0,
                             leading: 20,
                             bottom: 16,
                             trailing: 20))
        .listRowBackground(Color.brand1)
        .listRowSeparator(.hidden)
    }

}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .preferredColorScheme(.dark)
    }
}
