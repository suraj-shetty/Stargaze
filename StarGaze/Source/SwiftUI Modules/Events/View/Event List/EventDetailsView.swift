//
//  EventDetailsView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 28/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

// This view is dragged from bottom on the Events list screen
import SwiftUI
import Kingfisher
//import XCTest

struct BottomSheetView: View {
    @Binding var event: Event
    @Binding var isOpen: Bool
    
    let bottomAction: () -> Void

    @State var maxHeight: CGFloat = 0
    let minHeight: CGFloat = 30

    @GestureState private var translation: CGFloat = 0

    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.text1.opacity(0.6))
            .frame(
                width: 60,
                height: 4
        )
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator.padding()
                EventDetailsView(event: $event, contentHeight: $maxHeight, bottomAction: bottomAction)
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color.clear)
            .contentShape(Rectangle())
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    withAnimation(.spring()) {
                        state = value.translation.height
                    }
                }.onEnded { value in
                    let snapDistance = self.maxHeight * 0.25
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }
}

struct EventDetailsView: View {
    @Binding var event: Event
    @Binding var contentHeight: CGFloat
    let bottomAction: () -> Void

    @StateObject var viewModel = EventViewModel()
    @State var countdown: String = ""
    @State var scrollContentHeight: CGFloat = 0

    @State private var callRoom:VideoCallRoom?
    @State private var nameInput: Bool = false
    @State private var showWinners: Bool = false
    @State private var commentViewModel: SGCommentListViewModel? = nil
    @State private var buyCoins: Bool = false
//    @State private var shareLink: URL? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text(countdown)
                        .font(.walsheimRegular(size: 16))
                        .foregroundColor(.text1)
                        .padding(.top, 25)
                    Text("EVENT COUNT DOWN")
                        .font(.walsheimMedium(size: 8))
                        .foregroundColor(.text1.opacity(0.5))
                        .padding(.top, 5)
                    
                    DescriptionView(text: event.description)
                    
                    HStack {
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
                                    self.commentViewModel = SGCommentListViewModel(eventId: event.id, celebID: event.celebId)
                                }
                        }
                        
                        EventDataView(image: "multiple", value: event.participantsString)
                        EventDataView(image: "share", value: event.shareString)
//                            .onTapGesture {
//                                viewModel.shareLink(for: event) { url in
//                                    if let url = url {
//                                        self.shareLink = url
//                                    }
//                                }
//                            }
                    }
                    .padding(16)
                    
                    if event.showProbability() {
                        WinningProbabilityView(winPercent: event.probability)
                    }
                    
//                    Divider()
//                        .background(Color.tableSeparator)
//                        .padding(.horizontal, 36)
                    
                    
                    
//                    Text("\(event.postCount) posts by \(event.title)")
//                        .font(.walsheimRegular(size: 16))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .foregroundColor(.brand2)
//                        .padding(.horizontal, 36)
//                        .padding(.vertical, 18)
                    
                    winnerListView()
                }
                .frame(maxWidth: .infinity)
                .readSize { size in
                    let maximumSupportedContent = UIScreen.main.bounds.height - 224
                    let height = size.height > maximumSupportedContent ? maximumSupportedContent : size.height
                    // 98 is the Height of drag indicator and Bid to win button
                    contentHeight = height + 98
                    scrollContentHeight = height
                }
            }
            .background(Color.brand1)
            .cornerRadius(40)
            .frame(maxHeight: scrollContentHeight)
            
            bottomActionButton()
        }
        .background(Color.brand2)
        .cornerRadius(40, corners: [.topLeft, .topRight])
        .onReceive(timer) { value in
            if event.startDate < Date() {
                timer.upstream.connect().cancel()
                countdown = "0s"
            }
            else {
                countdown = event.startDate.countDown
            }
        }
        .onChange(of: viewModel.linkGenerating) { newValue in
            if newValue {
                SGAlertUtility.showHUD()
            }
            else {
                SGAlertUtility.hidHUD()
            }
        }
        .fullScreenCover(item: $callRoom) { room in
            SGVideoCallView(room: room)
        }
        .fullScreenCover(isPresented: $nameInput) {
            NameInputView()
        }
        .fullScreenCover(item: $commentViewModel, content: { viewModel in
            SGCommentListView(viewModel: viewModel)
        })
        .fullScreenCover(isPresented: $buyCoins) {
            InsufficientCoinsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .exitPayment)) { _ in
            self.buyCoins = false
        }
//        .sheet(item: $shareLink, content: { shareLink in
//            ShareSheet(activityItems: [shareLink]) { activityType, completed, returnedItems, error in
//                if completed {
//                    self.shareLink = nil
//                    self.feed.incrementShare()
//                }
//            }
//        })
    }
    
    @ViewBuilder
    private func bottomActionButton() -> some View {
        if event.isMyEvent() {
            switch event.status { //Is celebrity
            case .started, .ongoing, .aboutToStart:
                Button {
                    let room = VideoCallRoom(eventID: event.id,
                                             celebrityID: event.celebId,
                                             userID: (SGAppSession.shared.user.value?.id)!,
                                             userToken: SGAppSession.shared.token ?? "",
                                             canBroadcast: true,
                                             event: event)
                    
                    self.callRoom = room
                } label: {
                    Text("event.detail.start.videoCall".localizedKey)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.darkText)
                        .kerning(3.53)
                        .padding(.vertical, 21)
                }
                .opacity(event.isWinnersDeclared ? 1.0 : 0.5)
                .disabled(!event.isWinnersDeclared)
                
            case .upcoming:
                Button {
                    //Do nothing
                } label: {
                    Text("event.detail.start.videoCall".localizedKey)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.darkText)
                        .kerning(3.53)
                        .padding(.vertical, 21)
                    
                }
                .opacity(0.5)
                .disabled(true)
                
            default:
                Button {
                    //Do nothing
                } label: {
                    Text("event.detail.ended.title".localizedKey)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.darkText)
                        .kerning(3.53)
                        .padding(.vertical, 21)
                    
                }
                .opacity(0.5)
                .disabled(true)
            }
        }
        else { //For users, (winners & audience)
            if let userID = SGAppSession.shared.user.value?.id {
                if !event.isJoined {
                    switch event.status {
                    case .upcoming, .aboutToStart:
                        Button {
                            let balance = SGAppSession.shared.wallet.value?.goldCoins ?? 0
                            if balance < event.coins {
                                self.buyCoins = true
                            }
                            else {
                                if let userName = SGAppSession.shared.user.value?.name,
                                   !userName.isEmpty { //Participant's name is available
                                    viewModel.joinEvent(coinType: CoinType.gold.rawValue, eventId: event.id) { event in
                                        if event != nil {
                                            self.event = event!
                                        }
                                    }
                                }
                                else {
                                    withoutAnimation {
                                        self.nameInput = true //Show sheet to input user name
                                    }
                                }
                            }
                                                                                                                
                        } label: {
                            Text("events.join.count".formattedString(value: event.coins))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.darkText)
                                .kerning(3.53)
                                .padding(.vertical, 21)
                        }
                        
                    case .ended:
                        Button {
                            //Do nothing
                        } label: {
                            Text("event.detail.ended.title".localizedKey)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.darkText)
                                .kerning(3.53)
                                .padding(.vertical, 21)
                            
                        }
                        .disabled(true)
                        
                    default:
                        Button {
                            //Do nothing
                        } label: {
                            Text("event.detail.bid.cannot.title".localizedKey)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.darkText)
                                .kerning(3.53)
                                .padding(.vertical, 21)
                        }
                        .disabled(true)
                    }
                }
                else { //User joined the event
                    switch event.status {
                    case .upcoming, .aboutToStart:
                        Button {
                        bottomAction()
                    } label: {
                        Text("BID TO WIN")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.darkText)
                            .kerning(3.53)
                            .padding(.vertical, 21)
                    }

                    case .started, .ongoing:
                        if let winners = event.winners,
                            winners.contains(where: { $0.user.id == userID }) { //Can join as participant                            
                            Button {
                                let callRoom = VideoCallRoom(eventID: event.id,
                                                             celebrityID: event.celebId,
                                                             userID: userID,
                                                             userToken: SGAppSession.shared.token ?? "",
                                                             canBroadcast: true,
                                                             event: event)
                                self.callRoom = callRoom
                            } label: {
                                Text("event.detail.join.videoCall".localizedKey)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.darkText)
                                    .kerning(3.53)
                                    .padding(.vertical, 21)
                                
                            }
                            .disabled(event.status == .started)
                            .opacity(event.status == .started ? 0.5 : 1)
                        }
                        else { //Join as audience
                            Button {
                                let callRoom = VideoCallRoom(eventID: event.id,
                                                             celebrityID: event.celebId,
                                                             userID: userID,
                                                             userToken: SGAppSession.shared.token ?? "",
                                                             canBroadcast: false,
                                                             event: event)
                                self.callRoom = callRoom
                            } label: {
                                Text("event.detail.view.broadcast".localizedKey)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.darkText)
                                    .kerning(3.53)
                                    .padding(.vertical, 21)
                            }
                            .disabled(event.status == .started)
                            .opacity(event.status == .started ? 0.5 : 1)
                        }
                        
                    default: //Event ended so no action required
                        Button {
                            //Do nothing
                        } label: {
                            Text("event.detail.ended.title".localizedKey)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.darkText)
                                .kerning(3.53)
                                .padding(.vertical, 21)
                            
                        }
                        .disabled(true)
                    }
                }
            }
            else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private func winnerListView() -> some View {
        if let winners = event.winners, !winners.isEmpty {
            VStack(alignment: .leading, spacing: 20) {
                Divider()
                    .background(Color.tableSeparator)
                
                Button {
                    withAnimation {
                        self.showWinners.toggle()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text("Winners")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.brand2)
                        
                        Spacer()
                        
                        Image("disclosure")
                            .renderingMode(.template)
                            .tint(.brand2)
                            .rotationEffect(showWinners ? .degrees(0) : .radians(.pi/2))
                    }
                }
                .frame(height: 62)
                
                if showWinners {
                    VStack(spacing: 0) {
                        ForEach(winners) { winner in
                            EventWinnerView(winner: winner)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeIn, value: showWinners)
                }

            }
            .padding(.horizontal, 36)
        }
        else {
            EmptyView()
        }
        
        
    }
}

struct DescriptionView: View {
    let text: String
    var body: some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .font(.walsheimRegular(size: 15))
            .foregroundColor(.text1)
            .padding(.horizontal, 36)
            .padding(.top, 20)
    }
}

struct EventWinnerView: View {
    let winner: EventWinner
    var body: some View {
        HStack(alignment: .center, spacing: 9) {
            KFImage(URL(string: winner.user.picture ?? ""))
                .resizable()
                .setProcessor(
                    DownsamplingImageProcessor(size: CGSize(width: 44,
                                                            height: 44))
                )
                .cacheOriginalImage()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipShape(Capsule())
                .padding(4)
                .background(
                    Color.winnerBorder
                        .clipShape(Capsule())
                )
            
            VStack(alignment: .leading, spacing: -1) {
                Text(winner.user.name ?? "")
                    .foregroundColor(.text1)
                    .font(.system(size: 16, weight: .regular))
                    .frame(height: 24)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.5)
            }
            
            Spacer()
        }
        .frame(height: 70)
    }
}


extension Event {
    func isMyEvent() -> Bool { //To determine if current user is celebrity of this event
        guard let userID = SGAppSession.shared.user.value?.id
        else { return false }
        
        return celebId == userID
    }
    
    func showProbability() -> Bool {
        if isMyEvent() { //Current user is celebrity, so don't show probability meter
            return false
        }
                
        //Following conditions are for user, check if user joined
        if self.isJoined {
            switch status {
            case .upcoming, .aboutToStart:
                return true
                
            default:
                return false
            }
        }
                        
       return false
    }
}
