//
//  HomeView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var tabViewHeight: CGFloat = 0
    @State private var bottomInset: CGFloat = 0
    var body: some View {
        
        VStack(spacing: 0) {
            getContentView(type: viewModel.pickedTab)
                .cornerRadius(36, corners: [.bottomLeft, .bottomRight])
            
            TabBottomView(tabbarItems: TabType.allCases.map({ $0.tabItem}),
                          selectedIndex: $viewModel.tabIndex)
            .frame(height: 50)
            .padding(.bottom, UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        }
        .background(
            backgroundView()
                .ignoresSafeArea()
        )
        .onChange(of: viewModel.tabIndex) { newValue in
            let picked = TabType(rawValue: newValue) ?? .feeds
            switch picked {
            case .menu: SideMenuViewModel.shared.showMenu.toggle()
            default: self.viewModel.pickedTab = picked
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .menuDidHide)) { _ in
            self.viewModel.tabIndex = viewModel.pickedTab.rawValue
            //            self.selectedTabIndex = currentTab.rawValue
        }
        .fullScreenCover(item: $viewModel.rewards, content: { rewards in
            DailyRewardListView(list: rewards)
        })
        .onReceive(NotificationCenter.default.publisher(for: .redirectApp), perform: { output in
            guard let userInfo = output.userInfo,
                  let type = userInfo[NotificationUserInfoKey.redirectType] as? AppRedirectType
            else { return }
            
            switch type {
            case .feed(let int):
                self.viewModel.tabIndex = TabType.feeds.rawValue
                self.viewModel.feedsVM.getFeed(of: int)
                
            case .event(let id):
                self.viewModel.tabIndex = TabType.events.rawValue
                self.viewModel.eventsVM.loadEvent(with: id)
                
            case .celebrity(let int):
                self.viewModel.tabIndex = TabType.celebrities.rawValue
                let celebViewModel = viewModel.celebVM
                
                if celebViewModel.pickedCelebrity != nil {
                    celebViewModel.pickedCelebrity = nil
                    DispatchQueue.main.async {
                        celebViewModel.fetchCelebrity(with: int)
                    }
                }
                else {
                    self.viewModel.celebVM.fetchCelebrity(with: int)
                }
                
            }
            
        })
        .onAppear {
            viewModel.fetchDailyRewards()
            SGAppSession.shared.registerForRemoteNotification()
            
            if let payload = SGAppSession.shared.payload.value {
                SGAppSession.shared.payload.send(nil)
                SGAppSession.shared.handlePayload(payload)
            }
            
//            if let data = SGAppSession.shared.notifInfo {
//                
//                SGAlertUtility.showErrorAlert("From Appdele \(SGAppSession.shared.isAppdelegate)",
//                                              message: "\(data)")
//                
//                print("Notification data \(data)")
//                print("From Appdele \(data)")
//            }
            
        }
        .onReceive(SGAppSession.shared.payload) { output in
            if let payload = output {
                SGAppSession.shared.payload.send(nil)
                SGAppSession.shared.handlePayload(payload)
            }
        }
//        .onChange(of: SGAppSession.shared.payload) { newValue in
//            if let payload = SGAppSession.shared.payload {
//                SGAppSession.shared.payload = nil
//                SGAppSession.shared.handlePayload(payload)
//            }
//        }
    }
    
    @ViewBuilder
    private func getContentView(type: TabType) -> some View {
        switch type {
        case .feeds:
            FeedsListView(viewModel: viewModel.feedsVM)
            
        case .celebrities:
            SGCelebrityListView(viewModel: viewModel.celebVM)
            
        case .events:
            EventView(viewModel: viewModel.eventsVM)
                
        case .menu:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func backgroundView() -> some View {
        switch colorScheme {
        case .dark: Color.black.opacity(0.8)
                .blur(radius: 20)
            
        case .light: Color(uiColor: UIColor(rgb: 0xF1F1F1))
            
        default: Color(uiColor: UIColor(rgb: 0xF1F1F1))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
//            .preferredColorScheme(.dark)
    }
}
