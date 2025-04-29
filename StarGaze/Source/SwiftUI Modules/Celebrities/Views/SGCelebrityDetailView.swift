//
//  SSGCelebrityDetailView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 21/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
import Introspect
import Combine
import ToastUI

enum SGCelebContentType {
    case feeds
    case events
    //    case brands
}


struct SGCelebrityDetailView: View {
    @ObservedObject var celebrity:SGCelebrityViewModel
    
    @State private var currentIndex:Int = 0
    @State private var listType:SGCelebContentType = .feeds
    
    @State private var placeHolderHeight: CGFloat = 0
    @State private var scrollOffset: CGPoint = .zero
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var bioExpand: Bool = false
    @State private var loadSubscriptions: Bool = false
    @State private var showSubcSucessToast: Bool = false
    @State private var showMenu: Bool = false
    @State private var reportUser: Bool = false
    @State private var showBlockAlert: Bool = false
    @State private var shareLink: URL? = nil
    
    @StateObject private var feedListViewState = ViewState()
    
    private let segments = [
        SegmentItemViewModel(title: "Feeds", iconName: "feedsSegment"),
        SegmentItemViewModel(title: "Events", iconName: "mediaSegment")
    ]
    private let segmentViewID: String = UUID().uuidString
    private var isMyProfile: Bool = false
    
    @StateObject var feedSegments: FeedSegmentsViewModel
    @StateObject var eventSegments: EventSegmentsViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    init(celebrity:SGCelebrityViewModel) {
        let genericFeedList = FeedListViewModel(for: "\(celebrity.id)",
                                                type: .myFeeds,
                                                category: .generic)

//        let exclusiveFeedList = FeedListViewModel(for: "\(celebrity.id)",
//                                                  type: .myFeeds,
//                                                  category: .exclusive)
        
        let videoCalls  = CelebEventListViewModel(with: celebrity.celebrity,
                                                  type: .videoCall)
        let shows       = CelebEventListViewModel(with: celebrity.celebrity,
                                                  type: .show)
        
        let feedSegments    = FeedSegmentsViewModel(segments: [genericFeedList])
        
        let eventSegments   = EventSegmentsViewModel(segments: [videoCalls,
                                                                shows])
        
        _celebrity      = ObservedObject(initialValue: celebrity)
        _feedSegments   = StateObject<FeedSegmentsViewModel>(wrappedValue: feedSegments)
        _eventSegments  = StateObject<EventSegmentsViewModel>(wrappedValue: eventSegments)
        
        if let userID = SGAppSession.shared.user.value?.id, userID == celebrity.celebrity.id {
            self.isMyProfile = true
        }
        else {
            self.isMyProfile = false
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            switch listType {
            case .feeds:
                FeedList(segments: feedSegments,
                         parentProxy: proxy) {
                    Top {
                        headerView()
                    }
                    Header {
                        SegmentedView(id: segmentViewID,
                                      selectedIndex: $currentIndex.animation(),
                                      segments: segments)
                        .equatable()
                        .listRowBackground(Color.brand1)
                        .padding(.horizontal, 20)
                        .background(Color.brand1)
                    }
                }
                         .background(Color.brand1)
                         .environmentObject(feedListViewState)
                         .onAppear {
                             feedListViewState.isVisible = true
                         }
                         .onDisappear {
                             feedListViewState.isVisible = false
                         }
                
            case .events:
                CelebEventList(segments: eventSegments,
                               parentProxy: proxy,
                               placeholderHeight: $placeHolderHeight) {
                    Top {
                        headerView()
                    }
                    Header {
                        SegmentedView(id: segmentViewID,
                                      selectedIndex: $currentIndex.animation(),
                                      segments: segments)
                        .equatable()
                        .listRowBackground(Color.brand1)
                        .padding(.horizontal, 20)
                        .background(Color.brand1)
                    }
                }
                               .background(Color.brand1)
            }
        }
        .onChange(of: currentIndex) { newValue in
            switch newValue {
            case 1: listType = .events
            default: listType = .feeds
            }
        }
        .fullScreenCover(isPresented: $loadSubscriptions) {
            SubscriptionListView(celeb: Celeb(id: celebrity.celebrity.id,
                                              name: celebrity.name,
                                              picture: celebrity.picURL?.absoluteString ?? ""))
        }
        .onReceive(NotificationCenter.default.publisher(for: .packageAdded)) { _ in
            self.showSubcSucessToast = true
        }
        .onChange(of: shareLink) { newValue in
            let isLinkPresent = newValue != nil
            feedListViewState.isVisible = !isLinkPresent
        }
        .onChange(of: celebrity.linkGenerating) { newValue in
            if newValue {
                SGAlertUtility.showHUD()
            }
            else {
                SGAlertUtility.hidHUD()
            }
        }
        .onReceive(NotificationCenter.default
            .publisher(for: .redirectApp))
        { _ in
                self.shareLink = nil
            }
        
        .sheet(item: $shareLink, content: { shareLink in
            ShareSheet(activityItems: [shareLink]) { activityType, completed, returnedItems, error in
                if completed {
                    self.shareLink = nil
                }
            }
        })
        
        .toast(isPresented: $showSubcSucessToast,
               dismissAfter: 5) {
            if listType == .feeds {
                feedListViewState.isVisible = true
            }
        } content: {
            SGSuccessToastView(message: "Subscription added successfully")
        }
        .toastDimmedBackground(false)
    }
    
    private func headerView() -> some View {
        ZStack(alignment: .top) {
            navView()
            infoView()
                .onAppear {
                    if celebrity.shouldRefresh {
                        celebrity.getDetails()
                    }
                }
        }
        .background(
            GeometryReader { proxy in
                LinearGradient(stops: [.init(color: .clear, location: 0),
                                       .init(color: .darkText.opacity(0.97), location: 0.8),
                                       .init(color: .almostBlack, location: 1.0)],
                               startPoint: .top,
                               endPoint: .bottom)
                .blur(radius: 19)
                .opacity((colorScheme == .dark) ? 1.0 : 0.11)
                .onAppear {
                    self.calculatePlaceholderHeight(with: proxy.safeAreaInsets)
                }
            }
        )
        .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
        .listRowBackground(Color.brand1)
        .listRowSeparator(.hidden)
        .listRowInsets(.init())
    }
    
    private func navView() -> some View {
        HStack {
            Button {
                feedListViewState.isVisible = false
                dismiss()
            } label: {
                Image("navBack")
                    .frame(width: 49, height: 44)
            }
            
            Spacer()
            
            Button {
                self.showMenu = true
            } label: {
                Image("navOption")
                    .frame(width: 60, height: 44)
            }
            .opacity(isMyProfile ? 0 : 1)
        }
        .tint(.text1)
        .frame(height:44)
        .buttonStyle(.borderless)
        .confirmationDialog("", isPresented: $showMenu, actions: {
            Button("celebrity.profile.share.title") {
                celebrity.generateShareLink { url in
                    if let url = url {
                        self.shareLink = url
                    }
                }
            }
            
            Button("feed.list.dialog.report".localizedKey,
                   role: .destructive) {
                self.reportUser = true
            }
            
            if !celebrity.isBlocked {
                Button("feed.list.dialog.block".localizedKey,
                       role: .destructive) {
                    celebrity.block()
                }
            }
        })
        .fullScreenCover(isPresented: $reportUser, content: {
            ReportListView(userID: celebrity.celebrity.id)
        })
        .onReceive(NotificationCenter.default
            .publisher(for: .celebrityBlocked)) { _ in
                self.showBlockAlert = true
            }
        .toast(isPresented: $showBlockAlert, dismissAfter: 4) {
            SGSuccessToastView(message: "Celebrity is blocked")
        }
        .toastDimmedBackground(false)
    }
    
    private func followingButton() -> some View {
        Button {
            celebrity.toggleFollow()
        } label: {
            Text("celebrity.following.title".localizedKey)
                .foregroundColor(.darkText)
                .font(.system(size: 15, weight: .regular))
                .kerning(-0.09)
        }
        .frame(width:140, height:36)
        .background(Capsule()
            .fill(Color.celebBrand))
    }
    
    private func followButon() -> some View {
        Button {
            celebrity.toggleFollow()
        } label: {
            
            Text("celebrity.follow.title".localizedKey)
                .foregroundColor(.celebBrand)
                .font(.system(size: 15, weight: .regular))
                .kerning(-0.09)
        }
        .frame(width:140, height:36)
        .background(Capsule()
            .stroke(Color.brand2,
                    lineWidth: 1))
    }
    
    private func infoView() -> some View {
        VStack(alignment:.center, spacing: 20) {
            ZStack(alignment: .topLeading) {
                KFImage(celebrity.picURL)
                    .resizable()
                    .cancelOnDisappear(true)
                    .fade(duration: 0.25)
                    .scaleFactor(UIScreen.main.scale)
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 118,
                                                                          height: 118))
                    )
                    .cacheOriginalImage()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 118, height: 118)
                    .background(Color.text1.opacity(0.2))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.28), radius: 5, x: 0, y: 5)
                
                Image("trendingStar")
                    .frame(width: 24, height: 24)
                    .offset(x: 0, y: 9)
            }
            
            VStack(alignment: .center, spacing: 10) {
                Text(celebrity.name)
                    .font(.system(size: 30, weight: .bold))
                    .frame(height:33)
                    .foregroundColor(.text1)
                
                HStack(alignment: .center, spacing: 10) {
                    Text("events.count".formattedString(value: 1))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.text1)
                    
                    Capsule()
                        .fill(Color.text1)
                        .opacity(0.2)
                        .frame(width: 4, height: 4)
                    
                    Text("followers.count".formattedString(value: celebrity.followersCount))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.text1)
                }
                .frame(height:24)
                
//                ExpandableText(text: celebrity.bio,
//                               expand: $bioExpand)
                Text(celebrity.bio)
                .font(.system(size: 18,
                              weight: .regular))
                .foregroundColor(.text1)
                .lineSpacing(6)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
//                .highlightColor(.brand2)
//                .lineLimit(3)
//                .lineSpacing(6)
//                .expandAnimation(.easeInOut)
//                .expandButton(TextSet(text: NSLocalizedString("feed.list.description.read-more", comment: ""),
//                                      font: .system(size: 18, weight: .regular),
//                                      color: .brand2))
                                                
            }
            
            if !celebrity.isMyProfile {
                HStack(alignment: .center, spacing: 10) {
                    if celebrity.isFollowed {
                        followingButton()
                    }
                    else {
                        followButon()
                    }
                    
                    if !celebrity.isSubscribed {
                        Button {
                            withoutAnimation {
                                self.loadSubscriptions = true
                            }
                        } label: {
                            
                            Text("celebrity.subscribe".localizedKey)
                                .foregroundColor(.celebBrand)
                                .font(.system(size: 15, weight: .regular))
                                .kerning(-0.09)
                        }
                        .frame(width:140, height:36)
                        .background(Capsule()
                            .stroke(Color.brand2,
                                    lineWidth: 1))
                    }
                    else {
                        Button {
                        } label: {
                            Text("celebrity.message".localizedKey)
                                .foregroundColor(.celebBrand)
                                .font(.system(size: 15, weight: .regular))
                                .kerning(-0.09)
                        }
                        .frame(width:140, height:36)
                        .background(Capsule()
                            .stroke(Color.brand2,
                                    lineWidth: 1))
                        .opacity(0.5)
                        .disabled(true)
                    }
                }
                .padding(.bottom, 28)
            }
            else {
                Spacer()
            }
            
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
        .buttonStyle(.borderless)
        .overlay {
            if celebrity.isLoading {
                VStack {
                    HStack {
                        Spacer()
                        
                        LoaderToastView(message: NSLocalizedString("celebrity.profile.fetch.loading",
                                                                          comment: ""))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .disabled(true)
                .transition(.move(edge: .top))
                .animation(.spring(), value: celebrity.isLoading)
            }
            else {
                EmptyView()
            }
        }
    }
    
    //MARK: -
    private func calculatePlaceholderHeight(with inset:EdgeInsets) {
        let ht = UIScreen.main.bounds.height - 62 - inset.bottom - inset.top - 48.0 - 100.0// 62px is the segment control height
        if ht != placeHolderHeight {
            placeHolderHeight = ht
        }
    }
}

//struct SSGCelebrityDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SGCelebrityDetailView(celebrity: .preview)
//            .preferredColorScheme(.dark)
//    }
//}
