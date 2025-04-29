//
//  BlockedUserListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 09/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Shimmer

struct BlockedUserListView: View {
    @StateObject private var viewModel = BlockedListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    
                    Text("blocked-list.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                }
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image("navBack")
                            .tint(Color.text1)
                    }
                    .frame(width: 49, height: 49)

                    Spacer()
                }
            }
            
            if viewModel.list.isEmpty {
                if viewModel.didEnd {
                    PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                          title: "celebrity.list.empty.title",
                                                          message: "celebrity.list.empty.description"))                
                }
                else {
                    VStack(spacing: 20) {
                        ForEach((0..<5), id:\.self) { _ in
                            SGCelebCellView(viewModel: .preview)
                                .frame(height:56)
                                .background(content: {
                                    Color.brand1
                                })
                                .redacted(reason: .placeholder)
                                .shimmering()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .onAppear {
                        if !viewModel.loading,
                           !viewModel.didEnd,
                           viewModel.list.isEmpty {
                            viewModel.fetch()
                        }
                    }
                }
            }
            else {
                List {
                    ForEach(viewModel.list) { user in
                        BlockedUserCellView(user: user)
                            .frame(height:56)
                            .listRowBackground(Color.brand1)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 10,
                                                 leading: 20,
                                                 bottom: 10,
                                                 trailing: 20))
                    }
                    
                    if viewModel.didEnd == false {
                        Text("Fetching More…")
                            .foregroundColor(.text1)
                            .font(.walsheimRegular(size: 12))
                            .opacity(0.5)
                            .listRowBackground(Color.brand1)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 5,
                                                 leading: 20,
                                                 bottom: 5,
                                                 trailing: 20))
                            .onAppear {
                                viewModel.fetch()
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
    }
}

struct BlockedUserListView_Previews: PreviewProvider {
    static var previews: some View {
        BlockedUserListView()
    }
}
