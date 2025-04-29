//
//  EventSlideDataView.swift
//  StarGaze_Test
//
//  Created by Sourabh Kumar on 27/04/22.
//

import SwiftUI
import Combine
import Kingfisher

struct EventSlideDataView: View {
    @Binding var event: Event
    @StateObject var viewModel = EventViewModel()    
    @State private var commentViewModel: SGCommentListViewModel? = nil
    @EnvironmentObject var viewState: ViewState
    
    @State private var shareLink: URL? = nil
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: -3) {
                        Text(event.status.rawValue)
                            .foregroundColor(.text1)
                            .font(.louisianaRegular(size: 38))
                            .padding(-4)
                            .lineLimit(1)
                        Text(event.title.uppercased())
                            .multilineTextAlignment(.center)
                            .font(.brandonBlk(size: 46))
                            .foregroundColor(.text1)
                            .lineLimit(2)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 3)
                    
                    Text(event.description)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.walsheimRegular(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.text1)
                        .padding(.horizontal, 36)
                        .padding(.bottom, 20)
                        .lineLimit(2)
                    Text(event.displayDate)
                        .foregroundColor(.text1)
                        .frame(maxWidth: .infinity)
                        .font(.walsheimRegular(size: 16))
                        .padding(.bottom, 44)
                    
                    HStack(spacing: 26) {
                        Spacer()
                        
                        let likeImage = event.isLiked ? "likeFill" : "likeHollow"
                        EventDataView(image: likeImage, value: event.likeString)
                            .onTapGesture {
                                event.isLiked = !event.isLiked
                                viewModel.likeEvent(isLiked: !event.isLiked, eventId: event.id) { event in
                                    if event != nil {
                                        self.event = event!
                                    }
                                }
                            }
                        if event.isCommentOn {
                            EventDataView(image: "chatHollow", value: event.commentString)
                                .onTapGesture {
                                    self.viewState.isVisible = false
                                    self.commentViewModel = SGCommentListViewModel(eventId: event.id, celebID: event.celebId)
                                }
                        }
                        
                        EventDataView(image: "multiple", value: event.participantsString)
                        EventDataView(image: "share", value: event.shareString)
                            .onTapGesture {
                                self.viewModel.shareLink(for: self.event) { url in
                                    if let url = url {
                                        self.shareLink = url
                                    }
                                }
                            }
                        
                        Spacer()
                    }
                    .padding(.bottom, 64)
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [.brand1,
                                                               .brand1.opacity(0)]),
                                   startPoint: UnitPoint(x: 0.5, y: 0.6),
                                   endPoint: .top)
                    .padding(.top, -118)
                )
            }
            .background(content: {
                EventSlideMediaView(event: event)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
            })
            
            .fullScreenCover(item: $commentViewModel,
                             onDismiss: {
                viewState.isVisible = true
            }, content: { viewModel in
                SGCommentListView(viewModel: viewModel)
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
            .onReceive(NotificationCenter.default
                .publisher(for: .redirectApp)) { _ in
                    self.shareLink = nil
                }
        }
        .sheet(item: $shareLink, content: { shareLink in
            ShareSheet(activityItems: [shareLink]) { activityType, completed, returnedItems, error in
                if completed {
                    self.shareLink = nil
                    self.viewModel.incrementShareCount(for: event) { _ in
                        
                    }
//                    self.feed.incrementShare()
                }
            }
        })
    }
}

struct EventSlideMediaView: View {
    @StateObject private var viewModel: SGMediaViewModel
    
    init(event: Event) {
        let viewModel = SGMediaViewModel(Media(id: event.id,
                                               mediaPath: event.mediaPath,
                                               mediaType: event.mediaType))
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        contentView()
            .onAppear {
                viewModel.playMedia = true
            }
            .onDisappear {
                viewModel.playMedia = false
            }
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        switch viewModel.type {
        case .image:
            KFImage(viewModel.url)
                .resizable()
                .fade(duration: 0.25)
                .aspectRatio(contentMode: .fill)
            
        case .video:
            RemotePlayerView(media: viewModel)
            
        case .unknown:
            EmptyView()
        }
    }
}

//struct EventSlideDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventSlideDataView(event: .constant(Event.mockEvents[0]), viewModel: EventSlideDataViewModel(Event.mockEvents[0]))
//    }
//}
