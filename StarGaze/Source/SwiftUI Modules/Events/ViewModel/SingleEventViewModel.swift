//
//  SingleEventViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 16/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class SingleEventViewModel: ObservableObject, Equatable, Hashable {
    var event: Event
    
    @Published var isSliderOpen: Bool = false
    @Published var viewState: ViewState = ViewState()
    @Published var bidOffSet: CGFloat = 0
    @Published var bidCoins: Float = 0
    @Published var totalCoins: Int = 0
    
    @Published var shouldExit: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(event: Event) {
        self.event = event
        
        if let wallet = SGAppSession.shared.wallet.value {
            self.totalCoins = wallet.silverCoins
        }
    }
    
    deinit {
//        socketPublisher?.cancel()
//        socketManager.close()
        
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(event.id)
    }
    
    static func ==(lhs: SingleEventViewModel, rhs: SingleEventViewModel) -> Bool {
        return lhs.event.id == rhs.event.id
    }
    
        
    
    func bid() {
        bidEvent(coins: Int(bidCoins), eventId: event.id)
    }
    
    private func bidEvent(coins: Int, eventId: Int) {
        SGAlertUtility.showHUD()
        SGEventService.bidEvent(coins: coins, eventId: eventId)
            .sink { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    SGAlertUtility.showErrorAlert(message: error.errorDescription)
                    break
                case .finished:
                    break
                }
            } receiveValue: {[weak self] response in
//                self?.getEvents()
                if response {
                    self?.getWalletBalance()
                }
            }
            .store(in: &cancellables)
    }
    
    private func getWalletBalance() {
        SGWalletService.getWalletDetails()
            .sink { result in
                
            } receiveValue: {[weak self] wallet in
                SGAppSession.shared
                    .wallet
                    .send(wallet)
                
                self?.totalCoins = wallet.silverCoins
            }
            .store(in: &cancellables)

    }
    
    func getDetails() {
        
    }
    
    func handleSocketMessage(_ message:EventSocketMessage) {
        switch message {
        case .counter(let eventCounterUpdate):
            updateCounter(with: eventCounterUpdate)
            
        case .probabilityUpdate(let eventProbabilityUpdate):
            updateProbability(with: eventProbabilityUpdate)
            
        case .eventUpdate(let eventUpdate):
            handleEventUpdate(with: eventUpdate)
            
        case .notification:
            handleNotification()
        case .error(let error):
            print("Received error in event list \(error)")
        }
    }
}

private extension SingleEventViewModel {
    
    
    func updateCounter(with info: EventCounterUpdate) {
        guard info.eventID == event.id
        else { return }
                        
        switch info.type {
        case .newJoin:
            event.participatesCount = info.count
            
        case .comment:
            event.commentCount = info.count
            
        case .like:
            event.likeCount = info.count
            
        case .share:
            event.shareCount = info.count
        }

    }
    
    func updateProbability(with info: EventProbabilityUpdate) {
        guard info.eventID == event.id
        else { return }
        
        event.probability = Int(info.probability)
    }
    
    func handleEventUpdate(with info: EventUpdate) {
        switch info.type {
        case .eventUpdate, .callStart:
            guard info.eventID == event.id
            else { return }
            getDetails()
            
        case .eventDelete:
            guard info.eventID == event.id
            else { return }
            
            shouldExit = true
            
        }
    }
    
    func handleNotification() {
//        getEvents()
    }
}
