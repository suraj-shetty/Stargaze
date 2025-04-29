//
//  SGVideoCallViewController.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 12/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import SwiftUI
import AgoraRtcKit
import Combine
import Kingfisher

struct SGVideoCallView: View {
    @State var room: VideoCallRoom
    @State private var showExit: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if !showExit {
                SGVideoCallContentView(room: room, showExit: $showExit)
                    .ignoresSafeArea()
            }
            else {
                ZStack {
                    VStack(spacing: 0) {
                        HStack(alignment: .center) {
                            Button {
                                dismiss()
                            } label: {
                                Image("navBack")
                                    .tint(.text1)
                            }
                            .frame(width: 49, height:44)

                            Spacer()

                            Text("Call Ended")
                                .foregroundColor(.text1)
                                .font(.system(size: 18, weight: .medium))

                            Spacer()

                            Text("")
                                .frame(width: 49, height:44)
                        }
                        .background(
                            Color.brand1
                        )
                        
                        VStack { //Empty placeholder
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Color.brand1
                        )
                        .cornerRadius(36,
                                      corners: [.bottomLeft, .bottomRight])
                        
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("DONE")
                                    .foregroundColor(.darkText)
                                    .font(.system(size: 15, weight: .medium))
                                    .kerning(3.53)
                                Spacer()
                            }
                        }
                        .frame(height: 60)
                    }
                }
                .background(
                    Color.brand2
//                        .edgesIgnoringSafeArea(.bottom)
                )
            }
        }
        .background(Color.red.ignoresSafeArea())
    }
}

struct SGVideoCallContentView: UIViewControllerRepresentable {
    @State var room: VideoCallRoom
    @Binding var showExit: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = SGVideoCallViewController(room: room)
        controller.delegate = context.coordinator
        controller.navigationController?.isNavigationBarHidden = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, SGVideoCallDelegate {
        let parent: SGVideoCallContentView
        
        init(parent: SGVideoCallContentView) {
            self.parent = parent
        }
        
        //MARK: - SGVideoCallDelegate
        func callDidEnd() {
            parent.showExit = true
        }
    }
}

enum SGVideoLocalViewStatus {
    case none
    case shrinked
    case enlarged
}

enum SGOverlayTag: Int {
    case videoMute = 1001
    case lowNetwork
}

protocol SGVideoCallDelegate: NSObjectProtocol {
    func callDidEnd()
}

class SGVideoCallViewController: UIViewController {
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var remoteView: UIView!
    
    @IBOutlet weak var localViewTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var localViewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var localViewWidth: NSLayoutConstraint!
    @IBOutlet weak var localViewHeight: NSLayoutConstraint!

    @IBOutlet weak var remoteViewBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var audienceControlView: UIView!
    @IBOutlet weak var callControlView: UIView!

    @IBOutlet weak var winnerIconView: UIImageView!    
    @IBOutlet weak var celebIconView: UIImageView!
    
    @IBOutlet weak var participantsNameLabel: UILabel!
    @IBOutlet weak var broadcastViewerView: UIView!
    @IBOutlet weak var broadcastViewerLabel: UILabel!
        
//    @IBOutlet weak var remoteAudioMuteView: UIView!
//    @IBOutlet weak var localAudioMuteView: UIView!
        
    private var room: VideoCallRoom!
    
    private var agoraKit: AgoraRtcEngineKit?
    private var callSession: VideoCallChannel?
    
    private var socketManager: VideoCallSocketManager?
    private var socketSubscriber: AnyCancellable?
    
    private var callDurationLeft: TimeInterval = 0
    private var timer: Timer?
    
    weak var delegate: SGVideoCallDelegate?
    
    private var videoCallReady: Bool = false
    private var localViewStatus: SGVideoLocalViewStatus = .none
    private var currentRole: AgoraClientRole? = nil
    private var remoteUserID: UInt = 0
    private var localUserID: UInt = 0
    
    private var currentWinnerID: UInt = 0
    private var lastWinnerID: UInt = 0
    
    private weak var localStreamView: UIView? = nil
    private weak var remoteStreamView: UIView? = nil
    
    private weak var remoteOverlayView: UIView? = nil
    private weak var callView: UIView? = nil
    
    private let localStreamVM = LocalStreamViewModel()
    private let remoteStreamVM = CallStreamViewModel()
    private var cancellables = Set<AnyCancellable>()
 
    private var localAudioMuted: Bool = false
    private var localVideoMuted: Bool = false
    
    private var remoteUserJoined: Bool = false
    private var didJoin: Bool = false
    
    init(room: VideoCallRoom) {
        self.room = room
        super.init(nibName: "SGVideoCallViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        closeVideoCall()
        UIApplication.shared.isIdleTimerDisabled = false
        
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        view.insetsLayoutMarginsFromSafeArea = true
         
        initLocalViewConstraints()
        initiateVideoClient()
        initiateSocket()
        
        UIApplication.shared.isIdleTimerDisabled = true                
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        confirmExit()
    }
    
    @IBAction func videoOff(_ sender: UIButton) {
        localVideoMuted.toggle()
        
        sender.isSelected = localVideoMuted
        agoraKit?.muteLocalVideoStream(localVideoMuted)
    }
    
    @IBAction func mute(_ sender: UIButton) {
        localAudioMuted.toggle()
        
        sender.isSelected = localAudioMuted
        agoraKit?.muteLocalAudioStream(localAudioMuted)
    }
    
    @IBAction func swapVideo(_ sender: UIButton) {
        sender.isSelected.toggle()
        agoraKit?.switchCamera()
    }
    
    @IBAction func flagVideo(_ sender: Any) {
    }
    
    @IBAction func exitCall(_ sender: Any) {
        confirmExit()
    }
}

//MARK: - UI Setup/Update
private extension SGVideoCallViewController {
    func initLocalViewConstraints() {
        localViewWidth.constant = self.view.bounds.width
        localViewHeight.constant = self.view.bounds.height
    }
    
    func setupView() {
        setupCallControl()
        setupRemoteOverlayView()
        setupLocalOverlayView()
        
        broadcastViewerView.layer.cornerRadius = 14
        broadcastViewerView.layer.masksToBounds = true
                
        celebIconView.layer.cornerRadius = 23.0
        celebIconView.layer.masksToBounds = true
        
        winnerIconView.layer.cornerRadius = 23.0
        winnerIconView.layer.masksToBounds = true
        
        participantsNameLabel.text = ""
        updateViewCount(0)

        callControlView.isHidden = true
        remoteOverlayView?.isHidden = false
        audienceControlView.isHidden = false
    }
    
    func setupCallControl() {
        let callControlView = CallControlView(remoteViewModel: remoteStreamVM,
                                              localViewModel: localStreamVM)
        let callControlVC = UIHostingController(rootView: callControlView)
//        callControlVC.navigationController?.isNavigationBarHidden = true
        
        callControlVC.willMove(toParent: self)
        self.addChild(callControlVC)
        callControlVC.view.pin(to: self.callControlView)
        callControlVC.didMove(toParent: self)
                        
        localStreamVM.callCloseSubject
            .sink {[weak self] _ in
                self?.confirmExit()
            }
            .store(in: &cancellables)
        
        localStreamVM.cameraFlipSubject
            .sink {[weak self] _ in
                self?.agoraKit?.switchCamera()
            }
            .store(in: &cancellables)
        
        localStreamVM.flagSubject
            .sink { _ in
                print("Flag video")
            }
            .store(in: &cancellables)
        
        
        localStreamVM.$didMuteAudio
            .sink {[weak self] didMute in
                self?.agoraKit?.muteLocalAudioStream(didMute)
            }
            .store(in: &cancellables)
        
        localStreamVM.$didMuteVideo
            .sink {[weak self] didMute in
                self?.agoraKit?.muteLocalVideoStream(didMute)
            }
            .store(in: &cancellables)
    }
    
    func setupLocalOverlayView() {
        let vc = UIHostingController(rootView: CallStreamView(viewModel: localStreamVM,
                                                              alignment: .top))
        
        vc.willMove(toParent: self)
        self.addChild(vc)
        vc.view.pin(to: self.localView)
        vc.didMove(toParent: self)
    }
    
    
    func setupRemoteOverlayView() {
        let vc = UIHostingController(rootView: CallStreamView(viewModel: remoteStreamVM,
                                                              alignment: .bottom))
        
        vc.willMove(toParent: self)
        self.addChild(vc)
        vc.view.pin(to: self.remoteView)
        vc.didMove(toParent: self)
        
        self.remoteOverlayView = vc.view
    }
    
    
    func updateViewCount(_ count: Int) {
        let viewCountText = "viewers.count".formattedString(value: count)
        broadcastViewerLabel.text = viewCountText
        
        localStreamVM.viewCount = count
    }
    
    func setImage(with path: String?, to imageView: UIImageView) {
        imageView.kf.indicatorType = .activity
        
        let processor = DownsamplingImageProcessor(size: CGSize(width: 46, height: 46))
        
        if let picture = path, let url = URL(string: picture) {
            imageView.kf.setImage(with: url,
                                  placeholder: UIImage(named: "profilePlaceholder"),
                                  options: [
                                    .processor(processor),
//                                    .scaleFactor(UIScreen.main.scale),
                                    .transition(ImageTransition.fade(1)),
                                    .cacheOriginalImage
                                  ]) { _ in
                                  }
        }
        else {
            imageView.kf.cancelDownloadTask()
            imageView.image = UIImage(named: "profilePlaceholder")
        }
    }
    
    func maximizeLocalView() {
        guard localViewStatus != .enlarged
        else { return }
        
        self.localViewStatus = .enlarged
        print("\(Date())    Did maximize local view")
        
        let height = (self.navigationController?.view.bounds.height ?? self.view.bounds.height) / 2.0
        
        localViewWidth.constant = self.view.bounds.width
        localViewHeight.constant = height
        localViewBottomSpace.constant = 0
        localViewTrailingSpace.constant = 0
        
        remoteViewBottomSpace.constant = height
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        localView.layer.borderWidth = 0
        localView.layer.cornerRadius = 0
    }
    
    func minimizeLocalView() {
        guard localViewStatus != .shrinked
        else { return }
        
        self.localViewStatus = .shrinked
        print("\(Date())    Did shrink local view")
        
        localViewWidth.constant = 95
        localViewHeight.constant = 128
        localViewBottomSpace.constant = 128
        localViewTrailingSpace.constant = 20
        
        remoteViewBottomSpace.constant  = 0
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        localView.layer.borderWidth = 1
        localView.layer.borderColor = UIColor.white.cgColor
        localView.clipsToBounds = true
        localView.layer.cornerRadius = 14
    }
    
    func updateTimerDisplay() {
        localStreamVM.duration = callDurationLeft
        
        socketManager?.pingTimer()
    }
}

//MARK: - Socket flow
private extension SGVideoCallViewController {
    func initiateSocket() {
        guard room != nil else {
            fatalError("Video Call Room detail is missing")
        }
        
        let manager = VideoCallSocketManager()
        
        self.socketSubscriber = manager.messageSubject
            .receive(on: DispatchQueue.main)
            .sink {[weak self] message in
                switch message {
                case .system(let event):
//                    print("<!----- Received socket system events -----!>")
                    switch event {
                    case .connect: break
//                        guard let room = self?.room
//                        else { return }
//
//                        if room.userID == room.celebrityID {
//                            self?.joinCall()
//                        }

                    default: break
                    }
                    
                case .event(let event):
                    self?.handleVideoCallEvent(event)
                }
        }
                
        manager.connect(to: room) //Initiating connection with the current room
        self.socketManager = manager
    }
    
    func handleVideoCallEvent(_ event: VideoCallEvent) {
        switch event {
        case .celebStartCall(let callDetails):
            let channel = VideoCallChannel(id: callDetails.sessionID,
                                           token: callDetails.sessionToken)
            joinChannel(channel,
                        role: room.canBroadcast ? .broadcaster : .audience) //Join as broadcaster
            
        case .celebReady(let callInfo): //Received by participant
            
            guard !room.isCelebrity
            else { return }
            
            if callInfo.celebID != nil, callInfo.celebID! == "\(room.celebrityID)" {
                remoteUserJoined = true //Celebrity joined
            }
            
            let channel = VideoCallChannel(id: callInfo.sessionID,
                                           token: callInfo.sessionToken)
            
            if let winnerID = callInfo.winnerID {
                if winnerID == "\(room.userID)" {
                    joinChannel(channel, role: .broadcaster)
                }
                else {
                    joinChannel(channel, role: .audience)
                }
                self.currentWinnerID = UInt(winnerID) ?? 0
//                switchToUser(userID: UInt(winnerID) ?? 0)
            }
            else {
                maximizeLocalView()
                joinChannel(channel, role: .audience)
            }
            
            //callInfo.isSubscriber ? .audience : .broadcaster) //Join as audience if isSubscriber = true
            
        case .celebJoined(let info): //Celebrity joined event
            if info.eventID == "\(room.eventID)", !room.isCelebrity {
                remoteUserJoined = true //Celebrity joined
                runTimer()
            }
//            print("<!----- Celebrity Joined event -----!>")
            break
            
        case .celebPaused:
            break
//            print("<!----- Celebrity Paused video -----!>")
            
        case .celebLeft:
            closeVideoCall()
            self.delegate?.callDidEnd()
            break
//            print("<!----- Celebrity left call -----!>")
            
        case .winnerJoined(let callJoinedInfo):
//            print("<!----- Winner joined called. Can join \(callJoinedInfo.canConnect) -----!>")
//            print("<!----- Call duration left: \(callJoinedInfo.pendingDuration) -----!>")
            
            stopTimer()
            
            //For celebrity, set remote view to the winner (only if isConnect is true)
            if room.isCelebrity {
                if callJoinedInfo.canConnect {
                    switchToUser(userID: UInt(callJoinedInfo.winnerID) ?? 0)
                    self.callDurationLeft = callJoinedInfo.pendingDuration
                    self.remoteUserJoined = true
                    
                    runTimer()
                }
                else {//Celebrity can only talk to current winner, so no else condition to be handled
                    
                }
            }
            else {//For user, assign local view to the winner. If current user is winner, set broadcast role. Else set audience as role
                print("\(Date()) winner Joined, require handling from user side")
                
                switchToUser(userID: UInt(callJoinedInfo.winnerID) ?? 0)
                                
                if callJoinedInfo.winnerID == "\(room.userID)", callJoinedInfo.canConnect {
                    self.callDurationLeft = callJoinedInfo.pendingDuration
                    runTimer()
                }
                else {
//                    timerLabel.isHidden = true
                }
            }
            
                                    
        case .winnerLeft:
            stopTimer()
            break
//            print("<!----- Winner left -----!>")
            
        case .callPass(let callPassInfo):
            if !room.isCelebrity {
                print("\(Date()) User received callPassInfo")
//                switchToUser(userID: UInt(room.userID))
                
                self.currentWinnerID = UInt(room.userID)
                
                let channel = VideoCallChannel(id: callPassInfo.sessionID,
                                               token: callPassInfo.sessionToken)
                joinChannel(channel, role: .broadcaster)
                minimizeLocalView()
                
                stopTimer()
                self.callDurationLeft = callPassInfo.pendingDuration
                updateTimerDisplay()
                runTimer()
            }
            else {
                print("\(Date()) Celebrity received callPassInfo")
            }
                        
        case .callJoin(let joinCallInfo):
            guard "\(room.eventID)" == joinCallInfo.eventID
            else { return  }
            
            if !room.isCelebrity {
                print("\(Date()) User received joinCallInfo")
                
//                stopTimer()
                if joinCallInfo.connect {
                    if !didJoin {
                        switchToUser(userID: UInt(room.userID))
                    }
//                    else {
//                        runTimer()
//                    }
                }
                else {
                    updateRole(with: .audience)
                    maximizeLocalView()
                }
            }
            else {
                print("\(Date()) Celebrity received joinCallInfo")
            }
                        
        case .viewerCount(let countInfo):
            updateViewCount(countInfo.count)

            break
                        
        case .callEnded(_):
//            print("<!----- Call end received -----!>")
            closeVideoCall()
            self.delegate?.callDidEnd()
            
            break
            
        case .error(let error):
            print("<!----- Received error on socket \(error) -----!>")
            break
            
        case .streamUpdate:
            print("<!----- Received stream update -----!>")
        }
    }
}

private extension SGVideoCallViewController {
    func confirmExit() {
        let noAction = UIAlertAction(title: "No", style: .default)
        let yesAction = UIAlertAction(title: "Yes", style: .default) {[weak self] _ in
            self?.closeVideoCall()
            self?.delegate?.callDidEnd()
        }
        
        let alert = UIAlertController(title: "End Call?",
                                      message: "Are you sure you want to end call?", preferredStyle: .alert)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        alert.preferredAction = noAction
        
        present(alert, animated: true)
    }
    
    func runTimer() {
        print("Timer run called \(#function)")
        guard currentRole == .broadcaster
        else {
            print("Role is audience so no timer")
            return
        }
        
        if room.isCelebrity {
            guard didJoin, remoteUserJoined
            else { return }
        }
        else {
            guard remoteUserJoined, didJoin, UInt(room.userID) == currentWinnerID
            else {
                print("Remote user joined \(remoteUserJoined)")
                print("Did join \(didJoin)")
                print("Is current winner \(UInt(room.userID) == currentWinnerID)")
                return }
        }
        
        print("Timer running")
        
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
        
        updateTimerDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true,
                                     block: {[weak self] timer in
            guard let ref = self else {
                timer.invalidate()
                return
            }
            
            ref.callDurationLeft -= 1
            if ref.callDurationLeft < 0 {
                ref.callDurationLeft = 0
//                timer.invalidate()
            }
//            else {
            ref.updateTimerDisplay() //Display the decremented time
//            }
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    //MARK: - Agora setup and update methods
    func initiateVideoClient() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "043a9aa9d61240e3b504d77cc8717f08", delegate: self)
    }
    
    func closeVideoCall() {
        print("Close video call called")
        UIApplication.shared.isIdleTimerDisabled = false
        
        stopTimer()
        socketManager?.disconnect()
        
        socketSubscriber?.cancel() //Closing the socket communication
        agoraKit?.leaveChannel(nil)
        
        if room.isCelebrity || currentWinnerID == UInt(room.userID) {
            //If current broadcaster is leaving, notify others
            socketManager?.leaveCall(didPause: false)
        }
                
        //As per Agora's recommendation, setting view as nil to release memory resources
        //Reference https://docs.agora.io/en/Video/multi_user_video?platform=iOS#2-set-the-remote-video-stream-type
        agoraKit?.setupLocalVideo(nil)
        AgoraRtcEngineKit.destroy()
    }
    
    func switchToUser(userID: UInt) {
        guard currentWinnerID != userID
        else { return } //No need to switch to same winner again
         
        print("Switching to \(userID)")
        
        self.currentWinnerID = userID
    
        remoteStreamVM.reset()
        localStreamVM.reset()
        stopTimer()
        
        if room.isCelebrity { //For celebrity, send current stream to local view & user's stream to remote view
            if lastWinnerID != userID {
                agoraKit?.muteRemoteAudioStream(lastWinnerID, mute: true)
                agoraKit?.muteRemoteVideoStream(lastWinnerID, mute: true)
            }
                        
            updateRole(with: .broadcaster)
            minimizeLocalView()
            
//            localOverlayView?.isHidden = true
//            callControlView.isHidden = false
            
            assignLocalViewTo(userID: UInt(room.celebrityID))
            assignRemoteViewTo(userID: userID)
            
            agoraKit?.muteLocalVideoStream(localStreamVM.didMuteVideo)
            agoraKit?.muteLocalAudioStream(localStreamVM.didMuteAudio)
            
            agoraKit?.muteRemoteVideoStream(UInt(userID), mute: false)
            agoraKit?.muteRemoteAudioStream(UInt(userID), mute: false)
            
            print("Did unmute local")
            print("Did un-mute user \(userID)")
            
            if let celeb = room.event.celeb {
                localStreamVM.update(with: UInt(celeb.id ?? 0),
                                     name: celeb.name ?? "",
                                     avatarURL: URL(string: celeb.picture ?? ""))
            }
            else {
                localStreamVM.update(with: UInt(room.celebrityID),
                                     name: "",
                                     avatarURL: nil)
            }
            
            if let winner = room.event.winners?
                .first(where: { $0.user.id == Int(userID) })?.user {
                
                remoteStreamVM.update(with: userID,
                                      name: winner.name ?? "",
                                      avatarURL: URL(string: winner.picture ?? ""))
                
            }
            else {
                remoteStreamVM.update(with: userID,
                                      name: "",
                                      avatarURL: nil)
            }
        }
        else { //For other user, set local stream to userID & remote stream to celebrity
            if UInt(room.userID) != userID, UInt(room.celebrityID) != userID { // If picked winner is not current user
                if UInt(room.userID) == lastWinnerID {
                    agoraKit?.muteLocalVideoStream(true)
                    agoraKit?.muteLocalAudioStream(true)
                    
                    print("Others -> Local muted")
                }
                else {
                    print("Others -> muted for \(lastWinnerID)")
                    agoraKit?.muteRemoteVideoStream(lastWinnerID, mute: true)
                    agoraKit?.muteRemoteAudioStream(lastWinnerID, mute: true)
                }
            }
            
            //Assigning Celebrity to the remote stream
            if let celeb = room.event.celeb {
                remoteStreamVM.update(with: UInt(celeb.id ?? 0),
                                      name: celeb.name ?? "",
                                      avatarURL: URL(string: celeb.picture ?? ""))
            }
            else {
                remoteStreamVM.update(with: UInt(room.celebrityID),
                                      name: "",
                                      avatarURL: nil)
            }
            
            
            if let winner = room.event.winners?
                .first(where: { $0.user.id == Int(userID) })?.user {
                
                localStreamVM.update(with: userID,
                                     name: winner.name ?? "",
                                     avatarURL: URL(string: winner.picture ?? ""))
                
            }
            else {
                localStreamVM.update(with: userID,
                                     name: "",
                                     avatarURL: nil)
            }
                        
            
            if UInt(room.userID) == userID { //Its current participant
                updateRole(with: .broadcaster)
                minimizeLocalView()
                
//                localOverlayView?.isHidden = true
//                callControlView.isHidden = false
            }
            else {
                updateRole(with: .audience)
                maximizeLocalView()
                
//                localOverlayView?.isHidden = false
//                callControlView.isHidden = true
                
                var nameList = [String]()
                let celeb = room.event.celeb
                let winner = room.event.winners?.first(where: { $0.user.id == Int(userID) })
                
                if let celebName = celeb?.name, !celebName.isEmpty {
                    nameList.append(celebName)
                }
                
                if let winnerName = winner?.user.name, !winnerName.isEmpty {
                    nameList.append(winnerName)
                }
                
                let text = nameList.joined(separator: " & ")
                participantsNameLabel.text = text
                                                
                setImage(with: celeb?.picture, to: celebIconView)
                setImage(with: winner?.user.picture, to: winnerIconView)
            }
            
            assignRemoteViewTo(userID: UInt(room.celebrityID))
            assignLocalViewTo(userID: userID)

            print("Unmuted celebrity")
            
            agoraKit?.muteRemoteAudioStream(UInt(room.celebrityID), mute: false)
            agoraKit?.muteRemoteVideoStream(UInt(room.celebrityID), mute: false)
            
            if userID == UInt(room.userID) {
                print("Un-muted local")
                agoraKit?.muteLocalAudioStream(localAudioMuted)
                agoraKit?.muteLocalVideoStream(localVideoMuted)
                
            }
            else {
                print("Un-muted remote \(userID)")
                agoraKit?.muteRemoteAudioStream(UInt(userID), mute: false)
                agoraKit?.muteRemoteVideoStream(UInt(userID), mute: false)
            }
        }
        
        self.lastWinnerID = userID //After update complete
    }
    
    func assignLocalViewTo(userID: UInt) {
        guard userID != 0//, localUserID != userID
        else { return }
        
        print("\(Date())    switched local ID to \(userID)")
        self.localUserID = userID
        
        if localStreamView != nil { //Removing previous winner's stream
            localStreamView?.removeFromSuperview()
        }
        
        let streamView = UIView()
        streamView.pin(to: localView)
        localView.sendSubviewToBack(streamView)
        
        self.localStreamView = streamView
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = userID
        videoCanvas.renderMode = .hidden
        videoCanvas.view = streamView
        
        if room.userID == userID { //Its current user
            agoraKit?.setupLocalVideo(videoCanvas)
        }
        else { // Pausing last winner's stream, as a precaution
            agoraKit?.setupRemoteVideo(videoCanvas)
        }
    }
    
    func assignRemoteViewTo(userID: UInt) {

        self.remoteUserID = userID
        
        if remoteStreamView != nil {
            remoteStreamView?.removeFromSuperview()
        }
                
        let streamView = UIView()
        streamView.centerAlign(to: remoteView)
        streamView.setWidth(width: UIScreen.main.bounds.width)
        streamView.setHeight(height: UIScreen.main.bounds.height)
        streamView.setNeedsLayout()
        streamView.layoutIfNeeded()
        remoteView.sendSubviewToBack(streamView)
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = userID
        videoCanvas.renderMode = .hidden
        videoCanvas.view = streamView
        
        agoraKit?.setupRemoteVideo(videoCanvas)
        
        self.remoteStreamView = streamView
        
        print("\(Date())    setting remote ID to \(userID)")
    }
    
    //MARK: - Agora status management
    func joinChannel(_ channel: VideoCallChannel, role: AgoraClientRole) {
        if channel == self.callSession {
            updateRole(with: role)
            
            if role == .broadcaster {
                runTimer()
            }
            return
        }
        
        agoraKit?.leaveChannel()
        
        agoraKit?.enableDualStreamMode(true)
        agoraKit?.setRemoteSubscribeFallbackOption(.videoStreamLow)
        agoraKit?.setLocalPublishFallbackOption(.audioOnly)
        
        agoraKit?.joinChannel(byToken: channel.token,
                              channelId: channel.id,
                              info: nil,
                              uid: UInt(room.userID))
        self.callSession = channel
        updateRole(with: role)
    }
    
    func updateRole(with role: AgoraClientRole) {
        if currentRole == role {
            return
        }
        self.currentRole = role
        print("\(Date())    role switched to \((role == .broadcaster) ? "Broadcaster" : "Audience")")
        
        var option: AgoraClientRoleOptions? = nil
        if role == .broadcaster {
            //https://docs.agora.io/en/Video/multi_user_video?platform=iOS#recommended-video-profiles
            //Setting video configuration, as per the recommendation
            
            let config = AgoraVideoEncoderConfiguration()
            config.dimensions = AgoraVideoDimension640x360//  CGSize(width: 640, height: 360)
            config.frameRate = AgoraVideoFrameRate.fps15
            config.bitrate = 400
            config.minBitrate = 45
            config.degradationPreference = AgoraDegradationPreference.balanced
                    
            agoraKit?.enableVideo()
            
            callControlView.isHidden = false
            remoteOverlayView?.isHidden = true
            audienceControlView.isHidden = true
            
            localStreamVM.showMuteOverlay = false
//            celebHandleView.isHidden = room.isCelebrity //If current user is a winner, unhide the handle view
        }
        else {
            option = AgoraClientRoleOptions()
            option?.audienceLatencyLevel = .ultraLowLatency

            callControlView.isHidden = true
            remoteOverlayView?.isHidden = false
            audienceControlView.isHidden = false
            
            localStreamVM.showMuteOverlay = true
        }
        agoraKit?.setClientRole(role, options: option)
    }
    
    func joinCall() {
        guard room.canBroadcast, let manager = socketManager, manager.isConnected, videoCallReady, !didJoin
        else {
            return
        }
        
        self.didJoin = true
        manager.joinCall()
    }
}

//MARK: - AgoraRtcEngineDelegate
extension SGVideoCallViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("\(Date()) RTC Engine warning received \(warningCode)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("\(Date()) RTC Engine error received \(errorCode)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, networkTypeChanged type: AgoraNetworkType) {
        print("\(Date()) RTC Engine network type changed \(type)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState, reason: AgoraConnectionChangedReason) {
//        print("\(Date()) RTC Engine connection state changed \(state), reason \(reason)")
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("User with id = \(uid) joined channel \(channel)")
        
        self.videoCallReady = true
        
        if currentWinnerID != 0 {
            let winnerID = currentWinnerID
            
            currentWinnerID = 0
            switchToUser(userID: winnerID)
        }
        
        if room.isCelebrity, uid == UInt(room.celebrityID) { //If celebrity joined the channel
            joinCall()
        }
        else { //If participant joined the call
            if self.currentWinnerID == UInt(room.userID) { //If local straming view is set to current user
                print("\(Date()) Current participant joined the channel ")
                joinCall()
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.runTimer()
                }
            }
            else {
                print("\(Date()) Other participant with uid=\(uid) joined the channel")
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
//        if currentWinnerID != 0 {
//            let winnerID = currentWinnerID
//
//            currentWinnerID = 0
//            switchToUser(userID: winnerID)
//        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        self.videoCallReady = false
        
        print("\(Date()) RTC Engine did leave channel \(stats)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        print("\(Date()) RTC Engine Remote stream error of uid= \(uid)")
        print("Stream ID \(streamId)")
        print("Error \(error)")
        print("Missed \(missed)")
        print("Cached \(cached)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed: Int) {
        if state == .starting {
            if uid == remoteUserID {
                remoteStreamVM.updateState(.video(.unmute))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.video(.unmute))
            }
            return
        }
        
        switch reason {
        case .remoteMuted, .localMuted:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.video(.mute))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.video(.mute))
            }
            
        case .remoteUnmuted, .localUnmuted, .audioFallbackRecovery, .recovery:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.video(.unmute))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.video(.unmute))
            }
            
        case .remoteOffline:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.video(.offline))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.video(.offline))
            }
            print("Remote offline for \(uid)")
            
        case .congestion:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.video(.congession))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.video(.congession))
            }
            print("Congestion for \(uid)")
            
        case .audioFallback:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.video(.congession))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.video(.congession))
            }
            print("Fell back to audio only for \(uid)")
            
        case .internal:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.video(.offline))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.video(.offline))
            }
            print("Internal video issue for \(uid)")
            break
        @unknown default:
            break
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteReason, elapsed: Int) {
        switch reason {
        case .localMuted, .remoteMuted:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.audio(.mute))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.audio(.mute))
            }
            
        case .remoteUnmuted, .localUnmuted, .networkRecovery, .remoteOffline:
            if uid == remoteUserID {
                remoteStreamVM.updateState(.audio(.unMute))
            }
            else if uid == localUserID {
                localStreamVM.updateState(.audio(.unMute))
            }
            
        case .networkCongestion: //N/w issue
            if uid == remoteUserID {
                remoteStreamVM.updateState(.networkCongession)
            }
            else if uid == localUserID {
                localStreamVM.updateState(.networkCongession)
            }
            break
            
        case .internal: break
            
        @unknown default:
            break
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteUserStateChangedOfUid uid: UInt, state: UInt) {
        print("\(Date()) RTC Engine remote user state change of uid \(uid)")
        print("State \(state)")
    }
    
    // This callback is triggered when a remote user joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        print("\(Date()) RTC Engine offline of uid \(uid)")
        print("Reason \(reason)")
//        maximizeLocalView()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        print("\(Date()) RTC Engine remote stream message of uid \(uid)")
        print("Stream ID \(streamId)")
        print("Data \(data)")
        
        if let json = try? JSONSerialization.jsonObject(with: data) {
            print("JSON data \(json)")
        }
        else if let string = String(data: data, encoding: .utf8) {
            print("String data \(string)")
        }
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStateChangedOf state: AgoraVideoLocalState, error: AgoraLocalVideoStreamError, sourceType: AgoraVideoSourceType) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStateChanged state: AgoraAudioLocalState, error: AgoraAudioLocalError) {
        
    }
    
}
