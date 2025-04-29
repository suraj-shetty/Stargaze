//
//  SGFeedCardView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
import KMBFormatter

struct SGFeedCardView: View {
    @ObservedObject var feed:SGFeedViewModel
    
    private var canViewProfile: Bool = true
    private var mediaSize: CGSize = .zero
    
    @State private var celebViewModel: SGCelebrityViewModel? = nil
    @State private var commentViewModel: SGCommentListViewModel? = nil
    
    @State private var showMedia: Bool = false
    @State private var showSubscription: Bool = false
    @State private var showMenu: Bool = false
    @State private var confirmDelete: Bool = false
    @State private var confirmBlock: Bool = false
    @State private var reportUser: Bool = false
    @State private var viewProfile: Bool = false
        
    @State private var shareLink: URL? = nil
    
    @EnvironmentObject var viewState: ViewState
    @Environment(\.redactionReasons) private var reasons
    
    init(feed: SGFeedViewModel, canViewProfile: Bool = true) {
        self.feed = feed
        
        if feed.hasMedia {
            var aspectRatio = feed.mediaApectRatio.ratio
            if aspectRatio <= 0 {
                aspectRatio = 1
            }
            
            let width = UIScreen.main.bounds.width
            self.mediaSize = CGSize(width: width, height: (width / aspectRatio).rounded())
        }
        
        self.canViewProfile = canViewProfile
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            userInfoView()
            
            if feed.hasMedia {
                TabView(selection: $feed.currentMediaIndex) {
                    ForEach (Array(feed.media
                        .enumerated()),
                             id:\.1.id) { (index, media) in
                        self.cardView(for: media, showSubscription: feed.shouldSubscribe)
                            .tag(index)
                            .onTapGesture {
                                if feed.shouldSubscribe == false {
                                    self.showMedia = true
                                }
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(width: mediaSize.width,
                       height: mediaSize.height)
                .aspectRatio(contentMode: .fit)
//                .aspectRatio(feed.mediaApectRatio.ratio, contentMode: .fit)
//                .readSize(onChange: { size in //For certain ratio, the tabView size goes wrong, so calculating card size.
//                    let calculatedHeight = (size.width / feed.mediaApectRatio.ratio).rounded()
//                    if mediaSize.height != calculatedHeight {
//                        mediaSize = CGSize(width: size.width,
//                                           height: calculatedHeight)
//                    }
//                })
                .padding(.bottom, 20)
            }
            
            bottomContent()
        }
        //            .frame(maxWidth:.infinity)
        .buttonStyle(.borderless)
        .opacity(feed.isDeleting ? 0.5 : 1)
        .disabled(feed.isDeleting)
        .fullScreenCover(item: $commentViewModel, content: { viewModel in
            SGCommentListView(viewModel: viewModel)
        })
        .fullScreenCover(isPresented: $showMedia) {
            SGMediaPreviewView(viewModel: feed)
        }
        .fullScreenCover(item: $celebViewModel, content: { viewModel in
            SGCelebrityDetailView(celebrity: viewModel)
        })
        .fullScreenCover(isPresented: $showSubscription, content: {
            SubscriptionListView(celeb: feed.feed.celeb)
        })
        .fullScreenCover(isPresented: $reportUser, content: {
            ReportListView(userID: feed.celebID!)
        })
        
        .confirmationDialog("", isPresented: $showMenu, actions: {
            if feed.isMyFeed {
                Button("feed.list.dialog.delete".localizedKey,
                       role: .destructive) {
                    self.confirmDelete = true
                }
            }
            else {
                Button("feed.list.dialog.report".localizedKey,
                       role: .destructive) {
                    self.reportUser = true
                }
                
                Button("feed.list.dialog.block".localizedKey,
                       role: .destructive) {
                    self.confirmBlock = true
                }
            }
        })
        .alert("feed.delete.alert.title".localizedKey,
               isPresented: $confirmDelete, actions: {
            Button("alert.button.no.title", role: .cancel) {
            }
            
            Button("alert.button.yes.title", role: .destructive) {
                self.feed.delete()
            }
        })
        .alert("feed.block.alert.title".localizedKey,
               isPresented: $confirmBlock, actions: {
            Button("alert.button.no.title", role: .cancel) {
            }
            
            Button("alert.button.yes.title", role: .destructive) {
                self.feed.block()
            }
        })
        
        .sheet(item: $shareLink, content: { shareLink in
            ShareSheet(activityItems: [shareLink]) { activityType, completed, returnedItems, error in
                if completed {
                    self.shareLink = nil
                    self.feed.incrementShare()
                }
            }
        })
        .onChange(of: commentViewModel) { newValue in
            viewState.isVisible = (newValue == nil)
        }
        .onChange(of: showMedia) { newValue in
            viewState.isVisible = !newValue
        }
        .onChange(of: viewProfile) { newValue in
            viewState.isVisible = !newValue
        }
        .onChange(of: shareLink) { newValue in
            let isLinkPresent = newValue != nil            
            viewState.isVisible = !isLinkPresent
        }
        .onReceive(NotificationCenter.default
            .publisher(for: .redirectApp)) { _ in
                self.viewProfile = false
                self.reportUser = false
                self.showMedia = false
                self.showSubscription = false
                self.showMenu = false
                self.confirmBlock = false
                self.confirmDelete = false
                self.shareLink = nil
            }
    }
    
    private func userInfoView() -> some View {
        HStack(alignment: .center, spacing: 14, content: {
            Button {
                if canViewProfile, let celeb = feed.feed.celeb {
                    self.celebViewModel = SGCelebrityViewModel(celebrity: celeb.profile)
                }
            } label: {
                KFImage(feed.profileImageURL)
                    .resizable()
                    .cancelOnDisappear(true)
                    .fade(duration: 0.25)
                    .scaleFactor(UIScreen.main.scale)
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 52,
                                                                          height: 52))
                    )
                    .cacheOriginalImage()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .background(Color.text1.opacity(0.2))
                    .clipShape(Capsule())
                   
                VStack(alignment: .leading, spacing: 0) {
                    Text(feed.name)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.text1)
                        .frame(height:24)
                    
                    Text(feed.relativeDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.text1)
                        .opacity(0.5)
                        .frame(height:14)
                }
            }

            
            Spacer()
            
            Button {
                self.showMenu = true
            } label: {
                Image("moreInfo")
                    .renderingMode(.template)
                    .tint(.text1)
                    .opacity(0.7)
            }
            .frame(width: 44, height: 88)
        })
        .padding(.leading, 20)
    }
    
    private func cardView(for attachment: SGMediaViewModel, showSubscription: Bool) -> some View {
        switch attachment.type {
        case .image:
            if showSubscription {
                return AnyView(
                    feedImageView(for: attachment)
                        .overlay(content: {
                            ZStack(alignment: .center) {
                                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                                    
                                Button {
                                    withoutAnimation {
                                        self.showSubscription = true
                                    }
                                } label: {
                                    Text("feed.card.subscribe".localizedKey)
                                        .foregroundColor(.white)
                                        .underline()
                                        .fontWithLineHeight(font: .systemFont(ofSize: 16,
                                                                              weight: .regular),
                                                            lineHeight: 21)
                                        .frame(width: 268.0)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        })
                )
            }
            else {
                return AnyView(
                    feedImageView(for: attachment)
                )
            }
            
        case .video:
            if showSubscription {
                return AnyView (
                    ExclusiveVideoPlayer(media: attachment,
                                         showSubscription: $showSubscription)
                )
            }
            else {
                return AnyView(
                    RemotePlayerView(media: attachment)
                )
            }
            
        case .unknown:
            return AnyView(EmptyView())
        }
    }
    
    private func bottomContent() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if reasons.isEmpty {
                if !feed.title.isEmpty {
                    ExpandableText(text: feed.title,
                                   expand: $feed.descExpand, clickHandle: { element in
                        self.handleClick(element)
                    })
                    .lineSpacing(6)
                    .lineLimit(2)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.text1)
                    .highlightColor(.brand2)
                    .expandButton(TextSet(text: NSLocalizedString("feed.list.description.read-more",
                                                                  comment: ""),
                                          font: .system(size: 18,
                                                        weight: .regular),
                                          color: .brand2))
                    
                }
            }
            else {
                Text(feed.title)
                    .lineLimit(2)
                    .lineSpacing(6)
                    .font(.system(size: 18, weight: .regular))
            }
            
//            ExpandableText(feed.title,
//                           lineLimit: 3,
//                           font: .systemFont(ofSize: 18,
//                                             weight: .regular))
//            .multilineTextAlignment(.leading)
//            .lineSpacing(6)
//            .foregroundColor(.text1)
                        
            HStack(alignment: .top, spacing: 20) {
                Button { //Like button
                    feed.toggleLike()
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(feed.isLiked ? "likeFill" : "likeHollow")
                            .renderingMode(.template)
                            .tint(feed.isLiked ? Color.brand2 : Color.text1)
                        
                        Text(KMBFormatter.shared
                            .string(fromNumber: Int64(feed.likeCount)))
                        .foregroundColor(feed.isLiked ? .brand2 : .text1)
                        .font(.system(size: 14, weight: .medium))
                    }
                }
                
                if feed.allowComments { //Comments
                    Button {
                        self.commentViewModel = SGCommentListViewModel(viewModel: feed)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image("chat")
                                .renderingMode(.template)
                                .tint(Color.text1)
                            
                            Text(KMBFormatter.shared
                                .string(fromNumber: Int64(feed.commentCount)))
                            .foregroundColor(.text1)
                            .font(.system(size: 14, weight: .medium))
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    feed.shareLink { url in
                        if let url = url {
                            self.shareLink = url
                        }
                    }                    
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image("share")
                            .renderingMode(.template)
                            .tint(Color.text1)
                        
                        Text(KMBFormatter.shared
                            .string(fromNumber: Int64(feed.shareCount)))
                        .foregroundColor(.text1)
                        .font(.system(size: 14, weight: .medium))
                    }
                }
                
            }
            .frame(height:56)
            .onChange(of: feed.linkGenerating) { newValue in
                if newValue {
                    SGAlertUtility.showHUD()
                }
                else {
                    SGAlertUtility.hidHUD()
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func textWithHashtags(_ text: String, color: Color) -> Text {
        let words = text.split(separator: " ")
        var output: Text = Text("")

        for word in words {
            if word.hasPrefix("#") { // Pick out hash in words
                output = output + Text(" ") + Text(String(word))
                    .foregroundColor(color) // Add custom styling here
            } else {
                output = output + Text(" ") + Text(String(word))
            }
        }
        return output
    }
    
    private func feedImageView(for viewModel: SGMediaViewModel) -> some View {
        KFImage(viewModel.url)
            .resizable()
            .placeholder({
                HStack {
                    Spacer()
                    VStack(spacing: 14) {
                        Spacer()
                        
                        Image("imagePlaceHolder")
                        Text("video.loading.placeholder".localizedKey)
                            .font(.system(size: 12, weight: .medium))
                            .kerning(5)
                            .foregroundColor(.mediaTextPlaceholder)
                            .opacity(0.26)
                        
//                        ZStack(alignment: .bottom) {
//
////                                .resizable()
////                                .aspectRatio(contentMode: .fill)
//
//
//                        }
                        Spacer()
                    }
                    Spacer()
                }
                    .background(Color.mediaPlaceholder)
            })
            .cancelOnDisappear(true)
            .fade(duration: 0.25)
            .scaleFactor(UIScreen.main.scale)
            .setProcessor(DownsamplingImageProcessor(size: mediaSize))
            .cacheOriginalImage()
            .background(Color.text1.opacity(0.2))
            .aspectRatio(contentMode: .fill)
    }
    
//    @ViewBuilder
//    private func menuView() -> some View {
//        let cancelButton = Alert.Button.cancel()
//    }
    //MARK: -
    private func handleClick(_ element: ActiveElement) {
        switch element {
        case .mention(let string):
            print("Clicked mention \(string)")
        case .hashtag(let string):
            print("Clicked hashtag \(string)")
        case .email(let string):
            print("Clicked email \(string)")
        case .url(let original, _):
            if let url = URL(string: original) {
                UIApplication.shared.open(url)
            }
        case .custom(let string):
            print("Clicked custom \(string)")
        }
    }
}

//struct SGFeedCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        SGFeedCardView(feed: .preview)
//            .preferredColorScheme(.dark)
//    }
//}
