//
//  NotificationListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 21/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct NotificationListView: View {
    @EnvironmentObject private var menuViewModel: SideMenuViewModel
    @StateObject private var viewModel = NotificationListViewModel()
    var body: some View {
        VStack(spacing: 0) {
            navView()
                .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
            
            if viewModel.notifications.isEmpty {
                if viewModel.isLoading {
                    VStack(alignment: .center) {
                        Spacer()
                        
                        ProgressView()
                            .tint(.text1)
                            .scaleEffect(3)
                        
                        Spacer()
                    }
                }
                else {
                    emptyPlaceholderView()
                        .refreshable {
                            viewModel.fetch(refresh: true)
                        }
                }
            }
            else {
                List {
                    ForEach (viewModel.notifications, id:\.id) { notification in
                        NotificationCellView(viewModel: notification)
                            .listRowBackground(Color.brand1)
                            .listRowInsets(.init(top: 22,
                                                 leading: 20,
                                                 bottom: 22,
                                                 trailing: 20))
                            .listRowSeparator(.hidden,
                                              edges: .top)
                            .listRowSeparatorTint(.text2.opacity(0.06))
                    }
                    
                    if !viewModel.didEnd {
                        HStack {
                            Spacer()
                            Text("Fetching More…")
                                .foregroundColor(.text1)
                                .font(.system(size: 12, weight: .regular))
                                .opacity(0.7)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                                .onAppear {
                                    Task {
                                        viewModel.fetch(refresh: false)
                                    }
                                }
                                .listRowBackground(Color.brand1)
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init())
                            
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.bottom, UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
                .refreshable {
                    viewModel.fetch(refresh: true)
                }
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
        .onAppear {
            if viewModel.notifications.isEmpty, !viewModel.isLoading, !viewModel.didEnd {
                Task {
                    viewModel.fetch(refresh:true)
                }
            }
        }
    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("notifications.list.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 18,
                                  weight: .medium))
                
                Spacer()
            }
            
            HStack {
                Button {
                    menuViewModel.showMenu = true
                } label: {
                    Image("navBack")
                }
                .frame(width: 49,
                       height: 46)

                Spacer()
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea(.all,
                                 edges: .top)
        }
        .tint(.text1)
    }
    
    private func emptyPlaceholderView() -> some View {
        VStack(alignment: .center, spacing: 32) {
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                Image("emptyNotification")
                
                Text("0")
                    .font(.system(size: 52,
                                  weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 60)
                    .padding(.trailing, 26)
                    .padding(.top, 14)
            }
            
            Text("notifications.list.empty.title")
                .font(.system(size: 22,
                              weight: .medium))
                .foregroundColor(.text1)
                        
            Spacer()
        }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
    }
}
