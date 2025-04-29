//
//  SGMediaPreviewView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
import KMBFormatter

struct SGMediaPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel:SGFeedViewModel
    
    @State private var title:String = ""
    @State private var index = 0    
    
    @State private var showOverlay: Bool = true
    @State private var timer: Timer?
    @State private var expandDesc: Bool = false
    
    @StateObject var viewState = ViewState()
    @State var tileWidth: CGFloat = 0
    
    @State private var commentViewModel: SGCommentListViewModel? = nil
    @State private var shareLink: URL? = nil
    @State private var showSubscription: Bool = false
    
    var body: some View {
        ZStack {
            mediaView()
//                .ignoresSafeArea()
                navView()
                bottomView()
        }
        .animation(.linear(duration: 0.25), value: showOverlay)
        .background(Color.brand1)
        .onChange(of: viewModel.currentMediaIndex, perform: { newValue in
            self.title = "\(newValue+1) of \(viewModel.media.count)"
        })
        .onChange(of: shareLink) { newValue in
            let isLinkPresent = newValue != nil
            viewState.isVisible = !isLinkPresent
        }
        .onChange(of: viewModel.linkGenerating) { newValue in
            if newValue {
                SGAlertUtility.showHUD()
            }
            else {
                SGAlertUtility.hidHUD()
            }
        }
        .onAppear {
            if !viewModel.media.isEmpty {
                title = "1 of \(viewModel.media.count)"
                
                if timer == nil {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 5.0,
                                                      repeats: false,
                                                      block: { _ in
                        self.showOverlay.toggle()
                    })
                }                
            }
                        
            viewModel.allowPlaying = !viewModel.shouldSubscribe
            viewState.isVisible = !viewModel.shouldSubscribe
//            print("Media preview appeared")
        }
        .onDisappear(perform: {
//            print("Media preview disappeared")
            self.timer?.invalidate()
            self.timer = nil
            viewState.isVisible = false
        })
        .fullScreenCover(item: $commentViewModel, content: { viewModel in
            SGCommentListView(viewModel: viewModel)
        })
        .sheet(item: $shareLink, content: { shareLink in
            ShareSheet(activityItems: [shareLink]) { activityType, completed, returnedItems, error in
                if completed {
                    self.shareLink = nil
                    self.viewModel.incrementShare()
                }
            }
        })
        .fullScreenCover(isPresented: $showSubscription, content: {
            SubscriptionListView(celeb: viewModel.feed.celeb)
        })
        .onChange(of: viewModel.shouldSubscribe, perform: { newValue in
            if !newValue {
                viewModel.allowPlaying = true
                viewState.isVisible = true
            }
        })
        .preferredColorScheme(.dark)
    }
    
    private func navView() -> some View {
        VStack {
            if showOverlay {
                HStack {
                    Button {
                        viewState.isVisible = false
                        dismiss()
                    } label: {
                        Image("eRemove")
                    }
                    .frame(width:54)
                    
                    Spacer()
                    
                    Text(title)
                        .foregroundColor(.text1)
                        .font(Font.system(size: 18,
                                          weight: .medium,
                                          design: Font.Design.default))
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image("navOption")
                    }
                    .frame(width:60)
                    .hidden()
                    
                }
                .frame(height:54)
                .tint(.text1)
                .background(Color.brand1
                    .opacity(0.3)
                    .edgesIgnoringSafeArea(.top))
                .transition(.move(edge: .top))
            }
            
            Spacer()
        }
   }
    
    @ViewBuilder
    private func mediaView() -> some View {
        if !viewModel.shouldSubscribe {
            contentView()
        }
        else {
            contentView()
                .overlay(content: {
                    ZStack(alignment: .center) {
                        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                            .disabled(true)
                        
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
                                .lineLimit(2)
                        }
                    }
                })
        }
    }
    
    private func contentView() -> some View {
        ZStack {
            if viewModel.hasMedia {
                TabView(selection: $viewModel.currentMediaIndex.animation()) {
                        ForEach (Array(viewModel.media.enumerated()),
                                 id:\.1.id) { (index, media) in
                            self.cardView(for: media)
                                .tag(index)
                        }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(content: {
                    VStack {
                        Spacer()
                        
                        if viewModel.media.count > 1 {
                            FancyPageControl(numberOfPages: viewModel.media.count,
                                             currentIndex: viewModel.currentMediaIndex)
                        }
                    }
                })
                .readSize(onChange: { size in
                    self.tileWidth = size.width
                })
                .onTapGesture {
                    self.timer?.invalidate()
                    self.showOverlay.toggle()
                }
                
            }
        }
    }
    
    private func bottomView() -> some View {
        VStack {
            Spacer()
                        
            if showOverlay {
                VStack {
                    HStack {
                        VStack(alignment: .leading,
                               spacing: 2) {
                            Text(viewModel.name)
                                .font(.system(size: 18,
                                              weight: .regular,
                                              design: .default))
                                .foregroundColor(.text1)
                                .frame(height:24)
                            
                            Text(viewModel.relativeDate)
                                .font(.system(size: 14,
                                              weight: .regular,
                                              design: .default))
                                .foregroundColor(.text1)
                                .opacity(0.4)
                            
                            if !viewModel.title.isEmpty {
                                ExpandableText(text: viewModel.title,
                                               expand: $expandDesc) { element in
                                    switch element {
                                    case .mention(_):
                                        break
                                    case .hashtag(_):
                                        break
                                    case .email(_):
                                        break
                                    case .url(let original, _):
                                        if let url = URL(string: original) {
                                            UIApplication.shared.open(url)
                                        }
                                    case .custom(_):
                                        break
                                    }
                                }
                                               .foregroundColor(.text1.opacity(0.5))
                                               .font(.system(size: 18,
                                                             weight: .regular))
                                               .lineSpacing(6)
                                               .lineLimit(1)
                                               .expandButton(TextSet(text: NSLocalizedString("feed.list.description.read-more",
                                                                                             comment: ""),
                                                                     font: .system(size: 18,
                                                                                   weight: .regular),
                                                                     color: .brand2))
                                               .expandAnimation(.easeIn)
                            }
                        }
                               .padding(.vertical, 20)
                        
                        Spacer()
                    }
                    
                  Divider()
                        .background(Color.tableSeparator)
                    
                    HStack(alignment: .center,
                           spacing: 23) {
                        Button {
                            viewModel.toggleLike()
                        } label: {
                            
                            if viewModel.isLiked {
                                HStack(alignment: .center, spacing: 6) {
                                    Image("likeFill")
                                    
                                    Text(KMBFormatter.shared
                                        .string(fromNumber: viewModel.likeCount))
                                        .foregroundColor(.brand2)
                                        .font(.system(size: 14,
                                                      weight: .medium,
                                                      design: .default))
                                }
                            }
                            else {
                                HStack(alignment: .center,
                                       spacing: 6) {
                                    Image("likeHollow")
                                    
                                    Text(KMBFormatter.shared
                                        .string(fromNumber: viewModel.likeCount))
                                        .foregroundColor(.text1)
                                        .font(.system(size: 14,
                                                      weight: .medium,
                                                      design: .default))
                                }
                            }
                        }

                        if viewModel.allowComments {
                            Button {
                                self.commentViewModel = SGCommentListViewModel(viewModel: viewModel)
                            } label: {
                                HStack(alignment: .center, spacing: 6) {
                                    Image("chat")
                                    
                                    Text(KMBFormatter.shared.string(fromNumber: viewModel.commentCount))
                                        .foregroundColor(.text1)
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                }
                            }
                        }
                                                                        
                        Spacer()
                        
                        Button {
                            viewModel.shareLink { url in
                                if let url = url {
                                    self.shareLink = url
                                }
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 10) {
                                Image("shareHollow")
                                
                                Text(KMBFormatter.shared.string(fromNumber: viewModel.shareCount))
                                    .foregroundColor(.text1)
                                    .font(.system(size: 14, weight: .medium, design: .default))
                            }
                        }
                    }
                    .frame(height:49)
                }
                .padding(.horizontal, 20)
                .background(
                    Color.brand1.opacity(0.3)
                        .edgesIgnoringSafeArea(.bottom)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .tint(.text1)
    }
    
    //MARK: -
    private func cardView(for viewModel:SGMediaViewModel) -> some View {
        switch viewModel.type {
        case .image: return AnyView(imageCardView(for: viewModel))
        case .video: return AnyView(videoCardView(for: viewModel))
        case .unknown: return AnyView(EmptyView())
        }
    }
    
    private func imageCardView(for viewModel:SGMediaViewModel) -> some View {
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
                        
                        Spacer()
                    }
                    Spacer()
                }
                    .background(Color.brand1)
            })
            .aspectRatio(contentMode: .fit)
    }
    
    private func videoCardView(for viewModel:SGMediaViewModel) -> some View {
        RemotePlayerView(media: viewModel,
                         backgroundColor: .brand1,
                         contentMode: .scaleAspectFit)
        
//            .frame(width: tileWidth)
//            .aspectRatio(contentMode: .fit)
            .environmentObject(viewState)
    }
}

//struct SGMediaPreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        SGMediaPreviewView(viewModel: SGFeedViewModel.preview)
//            .preferredColorScheme(.dark)
//    }
//}
