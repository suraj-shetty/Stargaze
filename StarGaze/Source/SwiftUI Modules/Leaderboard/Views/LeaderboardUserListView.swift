//
//  LeaderboardUserListView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 29/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Introspect
import Shimmer

struct LeaderboardUserListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LeaderboardViewModel
    
    @State private var placeholderHeight: CGFloat = 0
    @State private var headerFrame: CGRect = .zero
    @State private var headerOffset: CGPoint = .zero
    @State private var navHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            navView()
                .zIndex(1)
            
            ZStack(alignment: .top) {
                if headerFrame != .zero {
                    let height = headerFrame.height + 31 - headerOffset.y
                    
                    Color.profileInfoBackground
                        .frame(width: headerFrame.width,
                               height: height)
                        .zIndex(0)
                        .cornerRadius(40,
                                      corners: [.bottomLeft,
                                                .bottomRight])
                    //31px is added so that the rounded view overlaps with first row (as per design)
                    //headerOffset.y is added, so that the background stretches when user pulls down the list
                }
                                
                List {
                    Color.clear
                        .frame(height: navHeight)
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden) //This view overlaps with the navView
                    
                    if viewModel.users.isEmpty {
                        if viewModel.isLoading {
                            ForEach (0..<5) { _ in
                                cellView(for: .preview)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                            }
                        }
                        else {
                            placeholder()
                        }
                    }
                    else {
                        headerView()
                        
                        ForEach (viewModel.users) { user in
                            cellView(for: user)
                        }
                        
                        listFooterView()
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                }
                .listStyle(.plain)
                .zIndex(1)
                .modifier(ListDidScrollViewModifier(didScroll: { offset in
                    self.headerOffset = offset
                }))
                .readSize { size in
                    self.placeholderHeight = size.height
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            Color.brand1
        )
        .onAppear {
            viewModel.getUsers(refresh: false)
        }
    }
    
    
    private func navView() -> some View {
        HStack(alignment: .center) {
            Button {
                self.dismiss()
            } label: {
                Image("navBack")
                    .tint(.text1)
                    .frame(minWidth: 49,
                           maxHeight: .infinity)
            }

            Spacer()
            
            Text(
                String(format: NSLocalizedString("leaderbard.user.list.title",
                                                 comment: ""),
                       viewModel.title)
            )
                .foregroundColor(.text1)
                .font(.system(size: 18,
                              weight: .medium))
            
            Spacer()
            
            Color.clear
                .frame(width: 49) //To center align the title
            
        }
        .frame(height: 45)
        .background(Color.profileInfoBackground)
        .readSize { size in
            self.navHeight = size.height
        }
    }
    
    private func headerView() -> some View {
        let topRankers = viewModel.users.filter({ $0.rank < 4}) //Considering top 3
        
        if topRankers.isEmpty {
            return AnyView(EmptyView())
        }
        else {
            return AnyView(
                LeaderboardRankView(users: topRankers)
                    .padding(.horizontal, 20)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .readFrame(space: .local,
                               onChange: { frame in
                                   self.headerFrame = frame
                               })
            )
        }
    }
    
    private func cellView(for user: LeaderboardUser) -> some View {
        LeaderboardUserCell(user: user)
            .listRowInsets(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
 
    private func listFooterView() -> some View {
                            
        if viewModel.didEnd == false,
            viewModel.users.isEmpty == false {
            return AnyView(
                Text("Fetching More…")
                    .foregroundColor(.text1)
                    .font(.system(size: 12, weight: .regular))
                    .opacity(0.5)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .onAppear {
                        viewModel.getUsers(refresh: false)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
            )
        }
        else {
            return AnyView(EmptyView())
        }
    }
    
    private func placeholder() -> some View {
        PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                              title: "leaderboard.empty".localizedKey,
                                              message: "NO_FEED_DESC".localizedKey))
        .listRowInsets(.init())
        .listRowBackground(Color.brand1)
        .listRowSeparator(.hidden)
        .padding(.horizontal, 25)
        .frame(maxWidth:UIScreen.main.bounds.width,
               minHeight:self.placeholderHeight,
               maxHeight:self.placeholderHeight)
    }
}

//struct LeaderboardUserListView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaderboardUserListView(viewModel: .preview)
////            .preferredColorScheme(.dark)
//    }
//}
