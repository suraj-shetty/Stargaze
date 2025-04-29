//
//  SGCelebrityListView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 19/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Shimmer

struct SGCelebrityListView: View {
    @ObservedObject var viewModel: CelebrityHomeViewModel
    @State private var loadSearch: Bool = false
    
    var body: some View {
        VStack {
            navView()
                .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
            
            listView()
            Spacer()
        }
        .background(
            Color.brand1
                .ignoresSafeArea()
        )
        .onAppear(perform: {
            let listViewModel = viewModel.listViewModel
            
            if !listViewModel.isLoading,
               !listViewModel.didEnd,
               listViewModel.celebrities.isEmpty {
                listViewModel
                    .fetchCelebrities(refresh: true)
            }
        })
        .fullScreenCover(item: $viewModel.pickedCelebrity,
                         onDismiss: {
            viewModel.pickedCelebrity = nil
        }, content: { celeb in
            SGCelebrityDetailView(celebrity: celeb)
        })
        .fullScreenCover(isPresented: $loadSearch,
                         content: {
            SearchView()
        })
    }
    
    private func navView() -> some View {
        HStack {
            Button {
                
            } label: {
                Image("navFilter")
                    .tint(.text1)
                    .frame(width:62)
            }
            .hidden()
            
            Spacer()
            
            Text("celebrity.list.title".localizedKey)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.text1)
            
            Spacer()
            
            Button {
                loadSearch = true
            } label: {
                Image("searchEvent")
                    .tint(.text1)
                    .frame(width:62)
            }

        }
        .frame(height:46)
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        if viewModel.trendingViewModel.didEnd,
            viewModel.trendingViewModel.celebrities.isEmpty {
           EmptyView()
        }
        else {
                VStack {
                    HStack(alignment: .center, spacing: 9) {
                        Image("trendingStar")
//                            .frame(width: 24, height: 24)
                        
                        Text("celebrity.list.trending.title".localizedKey)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.text1)
                        
                        Spacer()
                    }
                    .frame(height:30)
                    .padding([.horizontal, .top], 20)
                                        
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center,
                               spacing: 15) {
                            
                            if viewModel.trendingViewModel.celebrities.isEmpty == false {
                                ForEach(viewModel.trendingViewModel.celebrities) { celebrity in
                                    SGCelebTileView(viewModel: celebrity)
                                        .onTapGesture {
                                            viewModel.pickedCelebrity = celebrity
                                        }
                                }
                            }
                            
                            else if viewModel.trendingViewModel.isLoading {
                                ForEach((0..<5), id:\.self) { _ in
                                    SGCelebTileView(viewModel: .preview)
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                }
                            }
                        }
                               .frame(height:120)
                               .padding(.horizontal, 20)
                    }
                    .frame(height:123)
                    
                    Spacer()
                        .frame(height:20)
                    
                    Divider()
                        .foregroundColor(.tableSeparator)
                        .padding(.horizontal, 20)
                }
                    .listRowBackground(Color.brand1)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                    .onAppear(perform: {
                        let trendingViewModel = viewModel.trendingViewModel
                        
                        if !trendingViewModel.isLoading,
                           !trendingViewModel.didEnd,
                           trendingViewModel.celebrities.isEmpty {
                            trendingViewModel.fetchCelebrities(refresh: true)
                        }
                    })
        }
    }
    
    private func recommendedHeaderView() -> some View {
        Text("celebrity.list.recommended.title".localizedKey)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.text1)
            .opacity(0.5)
            .frame(height: 14, alignment: .leading)
            .padding(EdgeInsets(top: 18, leading: 20, bottom: 3, trailing: 20))
            .listRowBackground(Color.brand1)
            .listRowSeparator(.hidden)
            .listRowInsets(.init())
    }
    
    private func celebCellView(for celebrity:SGCelebrityViewModel) -> some View {
        SGCelebCellView(viewModel: celebrity)
            .frame(height:56)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .listRowBackground(Color.brand1)
            .listRowSeparator(.hidden)
            .listRowInsets(.init())
    }
    
    private func listView() -> some View {
        let listViewModel = viewModel.listViewModel
        
        return List {
            headerView()
            
            if listViewModel.celebrities.isEmpty {
                if listViewModel.isLoading {
                    recommendedHeaderView()
                        .listRowSeparator(.hidden)
                    
                    ForEach((0..<5), id:\.self) { _ in
                        celebCellView(for: .preview)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    }
                }
                else {
                    PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                          title: "celebrity.list.empty.title",
                                                          message: "celebrity.list.empty.description"))
                    .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                }
            }
            else {
                recommendedHeaderView()
                    .listRowSeparator(.hidden)
                
                ForEach(viewModel.listViewModel.celebrities) { celebrity in
                    celebCellView(for: celebrity)
                        .onTapGesture {
                            viewModel.pickedCelebrity = celebrity
                        }
                }
                
                if viewModel.listViewModel.didEnd == false {
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
                            viewModel.listViewModel
                                .fetchCelebrities(refresh: false)
                        }
                }
            }
        }
        .listStyle(.plain)
    }
    
}

struct SGCelebrityListView_Previews: PreviewProvider {
    static var previews: some View {
        SGCelebrityListView(viewModel: CelebrityHomeViewModel())
            .preferredColorScheme(.dark)
    }
}
