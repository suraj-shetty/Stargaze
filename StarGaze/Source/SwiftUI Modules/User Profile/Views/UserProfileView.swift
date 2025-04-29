//
//  UserProfileView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
//import WrappingStack
import KMBFormatter
import Introspect

enum UserProfileOption: Identifiable {
    var id: Self { self }
    
    case videoCalls
    case polls
    case shows
    case wallet
    case subscriptions
    
    var title: LocalizedStringKey {
        switch self {
        case .videoCalls: return "profile.videoCalls".localizedKey
        case .polls: return "profile.polls".localizedKey
        case .shows: return "profile.shows".localizedKey
        case .wallet: return "profile.wallet".localizedKey
        case .subscriptions: return "profile.subscriptions".localizedKey
        }
    }
    
//    var subTitle: String {
//        switch self {
//        case .videoCalls: return "79 Lorem ipsum dolor sit amet"
//        case .polls:
//            <#code#>
//        case .shows:
//            <#code#>
//        case .plans:
//            <#code#>
//        case .subscriptions:
//            <#code#>
//        }
//    }
    
    var iconName: String {
        switch self {
        case .videoCalls: return "menuProfile"
        case .polls: return "profilePolls"
        case .shows: return "profileShows"
        case .wallet: return "profileWallet"
        case .subscriptions: return "profilePolls"
        }
    }
}

enum UserProfileSectionType {
    case posts
    case subscriptions
    
    var title: LocalizedStringKey {
        switch self {
        case .posts: return "profile.header.posts".localizedKey
        case .subscriptions: return "profile.header.subs".localizedKey
        }
    }
}

struct UserProfileSection: Identifiable, Hashable {
    let id = UUID()
    let type: UserProfileSectionType
    let options: [UserProfileOption]
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


struct UserProfileView: View {
    @StateObject private var userViewModel =  UserViewModel()
    @EnvironmentObject private var menuViewModel: SideMenuViewModel
    @State private var pickedOption: UserProfileOption?
    
    private let sections: [UserProfileSection] = [
        UserProfileSection(type: .subscriptions, options: [.wallet]),//, .subscriptions]),
        UserProfileSection(type: .posts, options: [.videoCalls])//, .polls, .shows]),        
    ]
    
    @State private var didRequestUpdate: Bool = false
    @State private var editProfile: Bool = false
    
    var body: some View  {        
            VStack(spacing: 23) {
             //Nav bar view
                navView()
                    .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
                
                List {
                    infoView()
                    
                    ForEach (sections) { section in
                        Section {
                            ForEach(section.options, id:\.self) { option in
                                rowCell(for: option)
                            }

                        } header: {
                            sectionHeader(for: section.type)
                        }
                        .listSectionSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
//                .background(Color.brand1)
                .padding(.bottom, UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            }
            .background(
                Color.brand1
                    .ignoresSafeArea()
            )
            .overlay(content: {
                if userViewModel.isLoading {
                    LoaderToastView(message: NSLocalizedString("profile.fetch.title",
                                                                      comment: ""))
                    .disabled(true)
                    .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeIn, value: userViewModel.isLoading)
                }
                else {
                    EmptyView()
                }
                
            })
            .onAppear {
                let headerBackground = UIView()
                headerBackground.backgroundColor = .brand1
                
                UITableViewHeaderFooterView.appearance().backgroundView = headerBackground
                UITableView.appearance().sectionHeaderTopPadding = 0 //To remove the space between the info header view and the segmented view
                
                if SideMenuViewModel.shared.state == .hidden {
                    self.fetchUpdate()
                }
                
//                if self.didRequestUpdate == false {
//                    self.didRequestUpdate = true
                    
//                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .menuDidHide)) { _ in
                self.fetchUpdate()
                //            self.selectedTabIndex = currentTab.rawValue
            }
            .onReceive(NotificationCenter.default.publisher(for: .profileUpdated)) { _ in
                self.fetchUpdate()
            }
            .fullScreenCover(isPresented: $editProfile) {
                EditProfileView(viewModel: userViewModel)
            }
            .fullScreenCover(item: $pickedOption) { option in
                contentView(for: option)
            }

    }
    
    private func navView() -> some View {
        HStack(alignment: .center) {
            Button {
                menuViewModel.showMenu = true
            } label: {
                Image("navBack")
                    .tint(.text1)
            }
            .frame(width: 49, height: 44)
            
            Spacer()
            
            Text("profile.title".localizedKey)
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Button {
                self.editProfile = true
            } label: {
                Text("profile.edit")
                    .foregroundColor(.brand2)
                    .font(.system(size: 18, weight: .regular))
                    .underline(true, color: .brand2)
            }
            .frame(height: 44)
            .padding(.trailing, 20)
        }
    }
        
    private func infoView() -> some View {
        UserProfileInfoCard(userViewModel: userViewModel)
            .listRowBackground(Color.brand1)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 3, leading: 20, bottom: 30, trailing: 20))
    }
    
    private func sectionHeader(for type: UserProfileSectionType) -> some View {
        HStack(alignment: .center) {
            Text(type.title)
                .kerning(1.71)
                .foregroundColor(.text1)
                .font(.system(size: 12, weight: .regular))
                .opacity(0.2)
            
            Spacer()
        }
        .frame(height: 34)
        .listRowBackground(Color.brand1)
        .listSectionSeparator(.hidden)
//        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
//        .listRowSeparator(.hidden)
    }
    
    private func rowCell(for option: UserProfileOption) -> some View {
        HStack(alignment: .center, spacing: 15) {
            Image(option.iconName)
                .renderingMode(.template)
                .tint(.profileMenuIcon)
            
            Text(option.title)
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .regular))
            
            Spacer()
            
            Image("disclosure")
                .renderingMode(.template)
                .tint(.text2)
        }
        .frame(height: 60)
        .listRowBackground(Color.brand1)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparatorTint(.profileSeperator)
        .onTapGesture {
            self.pickedOption = option
        }
    }
    
    @ViewBuilder
    private func contentView(for option: UserProfileOption) -> some View {
        switch option {
        case .videoCalls:
            EventHistoryView(type: .videoCall)
        case .polls:
            EmptyView()
        case .shows:
            EmptyView()
        case .wallet:
            MyWalletView()
        case .subscriptions:
            EmptyView()
        }
    }
    //MARK: -
    private func fetchUpdate() {
        userViewModel.fetchUpdates()
    }
}


private struct UserProfileInfoCard: View {
    @ObservedObject var userViewModel: UserViewModel
    @State var editProfile: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading,
               spacing: 25) {
            HStack(alignment: .center,
                   spacing: 20) {
                ZStack(alignment: .center) {
                    KFImage(userViewModel.profileURL)
                        .resizable()
                        .placeholder({
                            Image("profilePlaceholder")
                                .aspectRatio(contentMode: .fill)
                                .padding(8)
                        })
                        .fade(duration: 0.25)
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fill)
                        .padding(8)
                        .clipShape(Capsule())
                    
                }
                .frame(width: 107, height: 107)
                .background(
                    Color.profileInfoBackground
                )
                .clipShape(Capsule())
                
                VStack(alignment: .leading,
                       spacing: 12) {
                    
                    if !userViewModel.name.isEmpty {
                        Text(userViewModel.name)
                            .foregroundColor(.text1)
                            .font(.system(size: 27, weight: .medium))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.5)
                    }
                    
                    VStack(alignment: .leading,
                           spacing: 6) {
                        if !userViewModel.phoneNumberText.isEmpty {
                            infoView(title: "profile.phone",
                                     value: userViewModel.phoneNumberText)
                        }
                        
                        if !userViewModel.emailAddress.isEmpty {
                            infoView(title: "profile.email",
                                     value: userViewModel.emailAddress)
                        }
                    }
                    
//                    Spacer()
                }
                
            }
            
            HStack(alignment: .center,
                   spacing: 0) {
                goldCoinView()
                
                Divider()
                    .foregroundColor(
                        Color(uiColor: .init(rgb: 0x979797))
                            .opacity(0.14)
                    )
                    .padding(.vertical, 15)
                
                silverCoinView()
            }
                   .frame(height: 71)
                   .background(
                    Color.profileInfoBackground
                        .cornerRadius(11)
                   )
        }
    }
//    {
//        VStack(alignment: .center,
//               spacing: 20) {
//            HStack(alignment: .top) {
//                Color.clear
//                    .frame(width: 49, height: 49) //Matching with edit button size
//                Spacer()
//
//                ZStack(alignment: .topLeading) {
//                    KFImage(userViewModel.profileURL)
//                        .resizable()
//                        .placeholder({
//                            Image("profilePlaceholder")
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 108, height: 108)
//                        })
//                        .fade(duration: 0.25)
//                        .cancelOnDisappear(true)
//                        .frame(width: 108, height: 108)
//                        .aspectRatio(contentMode: .fill)
//                        .clipShape(Capsule())
//                        .shadow(color: .black.opacity(0.14),
//                                radius: 25,
//                                x: 0, y: 5)
//
//                    Image("trendingStar")
//                        .frame(width: 24, height: 24)
//                        .offset(x: 0, y: 9)
//                }
//                .frame(width: 108, height: 108)
//
//                Spacer()
//
//                Button {
//                    editProfile.toggle()
//                } label: {
//                    Image("profileEdit")
//                        .frame(width: 49, height: 49)
//                }
//                .background(
//                    NavigationLink(destination: EditProfileView(viewModel: userViewModel),
//                                   isActive: $editProfile,
//                                   label: {
//                                       EmptyView()
//                                   })
//                    .hidden()
//                )
//            }
//            .padding(.horizontal, 20)
//
//            VStack(spacing: 10) {
//                if userViewModel.name.isEmpty == false {
//                    Text(userViewModel.name)
//                        .foregroundColor(.text1)
//                        .font(.system(size: 30, weight: .bold))
//                        .frame(height: 33)
//                }
//
//                if userViewModel.role == .celebrity {
//                    VStack(spacing: 15) {
//                        HStack(alignment: .center, spacing: 10, content: {
//                            Text(userViewModel.eventCountText)
//                                .foregroundColor(.text2)
//                                .font(.system(size: 16, weight: .regular))
//
//                            Color.text1
//                                .opacity(0.2)
//                                .frame(width: 4, height: 4)
//                                .clipShape(Capsule())
//
//                            Text(userViewModel.followersCountText)
//                                .foregroundColor(.text2)
//                                .font(.system(size: 16, weight: .regular))
//
//                    })
//                        .frame(height: 24)
//
//                        Text(userViewModel.subscribersCountText)
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(.celebBrand)
//                            .frame(height: 18)
//                            .padding(EdgeInsets(top: 9,
//                                                leading: 20,
//                                                bottom: 9,
//                                                trailing: 20))
//                            .background(
//                                Color.celebBrand
//                                    .opacity(0.1)
//                                    .clipShape(Capsule())
//                            )
//                    }
//                }
//                else {
//                    HStack(alignment: .center, spacing: 4) {
//                        Image("phoneIcon")
//
//                        Text(userViewModel.phoneNumberText)
//                            .foregroundColor(.text2)
//                            .font(.system(size: 15,
//                                          weight: .regular))
//                            .frame(height: 24)
//                            .opacity(0.5)
//
//                    }
//                }
//            }
//
//            if userViewModel.role == .celebrity {
//                VStack(spacing: 16) {
//                    Text(userViewModel.bioText)
//                        .foregroundColor(.text2)
//                        .font(.system(size: 16, weight: .regular))
//                        .lineSpacing(6)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 20)
//
//
//                    WrappingHStack(id: \.self,
//                    horizontalSpacing: 9,
//                    verticalSpacing: 9) {
//                        ForEach(userViewModel.hashtags, id:\.self) { hashtag in
//                            Button {
//
//                            } label: {
//                                Text(hashtag)
//                                    .foregroundColor(.text2)
//                                    .font(.system(size: 14,
//                                                  weight: .medium))
//                                    .opacity(0.43)
//                                    .padding(EdgeInsets(top: 4,
//                                                        leading: 20,
//                                                        bottom: 6,
//                                                        trailing: 20))
//                                    .background(
//                                        Rectangle()
//                                            .foregroundColor(Color.text2
//                                                .opacity(0.2))
//                                            .opacity(0.3)
//                                            .clipShape(Capsule())
//                                    )
//
//                            }
//                        }
//                    }
//                    .fixedSize(horizontal: false, vertical: false)
////                    .frame(maxWidth:.infinity, minHeight: 30)
//                }
//            }
//
//            Divider()
//                .foregroundColor(.profileSeperator)
////                .padding(.horizontal, -20)
//
//
//            HStack(alignment: .center) {
//                tabView(with: "profile.wild.coins", count: Int64(userViewModel.wildCoinsCount))
//                Spacer()
//                tabView(with: "profile.coins", count: Int64(userViewModel.balanceCoins))
//
//                if userViewModel.role == .user {
//                    Spacer()
//                    tabView(with: "profile.followings",
//                            count: Int64(userViewModel.followingsCount))
//                }
//
//            }
//            .padding(.horizontal, userViewModel.role == .user ? 16 : 36)
//            .frame(height: 57)
//
//        }
//               .padding(EdgeInsets(top: 30, leading: 0, bottom: 20, trailing: 0))
//               .background(
//                Color.profileInfoBackground
//                    .cornerRadius(27)
//               )
//    }
    
    @ViewBuilder
    private func goldCoinView() -> some View {
        
        coinTabView(title: Text("profile.coins.gold")
            .foregroundColor(.celebBrand)
            .font(.system(size: 13, weight: .regular))
            .kerning(2.17)
            .opacity(0.5),
                    icon: "goldCoin",
                    count: Text(KMBFormatter.shared
                        .string(fromNumber: Int64(userViewModel.goldCoinsCount)))
                        .foregroundColor(.text1)
                        .font(.system(size: 19, weight: .medium))
        )
    }
    
    @ViewBuilder
    private func silverCoinView() -> some View {
        
        coinTabView(title: Text("profile.coins.silver")
            .foregroundColor(.text1)
            .font(.system(size: 13, weight: .regular))
            .kerning(2.17)
            .opacity(0.5),
                    icon: "silverCoin",
                    count: Text(KMBFormatter.shared
                        .string(fromNumber: Int64(userViewModel.silverCoinsCount)))
                        .foregroundColor(.text1)
                        .font(.system(size: 19, weight: .medium))
        )
    }
    
    
    @ViewBuilder
    private func coinTabView(title: some View,
                             icon: String,
                             count: some View) -> some View {
        
        HStack(alignment: .center,
               spacing: 0) {
            Spacer()
            
            VStack(alignment: .center, spacing: 3) {
                title
                
                HStack(alignment: .center,
                       spacing: 9) {
                    Image(icon)
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                    
                    count
                }
            }
            Spacer()
        }
    }
    
    private func tabView(with title: LocalizedStringKey,
                         count:Int64) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text(KMBFormatter.shared
                .string(fromNumber: count))
            .foregroundColor(.maize2)
            .font(.system(size: 24, weight: .medium))
            .frame(height: 33)
            
            Text(title)
                .kerning(2.17)
                .foregroundColor(.text2)
                .font(.system(size: 13, weight: .regular))
                .opacity(0.5)
                .frame(height: 24)
        }
        .frame(width: 100)
    }
    
    @ViewBuilder
    private func infoView(title: LocalizedStringKey,
                          value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.text1)
                .opacity(0.5)
            
            Text(value)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.text1)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Spacer()
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileInfoCard(userViewModel: .init())
//            .preferredColorScheme(.dark)
    }
}
