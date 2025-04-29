//
//  EventListViewModel.swift
//  StarGaze_Test
//
//  Created by Sourabh Kumar on 27/04/22.
//

import Foundation
import SwiftUI
import Combine

final class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedIndex = 0
    @Published var eventAddInitiate: Bool = false
    @Published var bidOffSet: CGFloat = 0
    @Published var bidCoins: Float = 0
    @Published var totalCoins: Int = 0

    @Published var viewState: ViewState = ViewState()
    
    @Published var eventViewModel: SingleEventViewModel? = nil
    
    var eventsFetched: Bool = false
    let isCelebrityMode: Bool = SGAppSession.shared.user.value?.role == .celebrity
    
    private var cancellables = Set<AnyCancellable>()
    private var socketPublisher: AnyCancellable?
    private var notificationSubscribers = Set<AnyCancellable>()
    
    private let socketManager = EventSocketManager()
    
//    private var selectedEvent: Event? {
//        if events.count > selectedIndex {
//            return events[selectedIndex]
//        }
//        return nil
//    }
    
    private var filters: [SGFilter] = []
    
    
    deinit {
        socketPublisher?.cancel()
        socketManager.close()
        
        notificationSubscribers.forEach({ $0.cancel() })
        notificationSubscribers.removeAll()
    }
    
    init() {
        NotificationCenter.default
            .publisher(for: .celebrityBlocked)
            .sink {[weak self] notification in
                let userInfo = notification.userInfo
                if let type = userInfo?[AppUpdateNotificationKey.updateType] as? AppUpdateType {
                    self?.handleAppUpdate(type: type)
                }
            }
            .store(in: &notificationSubscribers)
    }
    
    // MARK: - UI Vars
    var isPreviousEnabled: Bool {
        if events.count == 0 {
            return false
        }
        return selectedIndex != 0
    }
    
    var isNextEnabled: Bool {
        if events.count == 0 {
            return false
        }
        return selectedIndex != events.count - 1
    }
    
    var previousImage: String {
        if isPreviousEnabled {
            return events[selectedIndex-1].mediaPath
        }
        return ""
    }
    
    var nextImage: String {
        if isNextEnabled {
            return events[selectedIndex+1].mediaPath
        }
        return ""
    }
    
    func tag(for event: Event) -> Int {
        return events.firstIndex(of: event) ?? 0
    }
    
    // MARK: -  Actions
    func fetchEvents() {
        events = Event.mockEvents
    }
    
    func previousAction() {
        if selectedIndex > 0 {
            withAnimation {
                selectedIndex -= 1
            }
        }
    }
    
    func nextAction() {
        if selectedIndex < events.count - 1 {
            withAnimation {
                selectedIndex += 1
            }
        }
    }
    
    func addEvent() {
        eventAddInitiate = true
    }
}


// MARK: - Networking
extension EventListViewModel {
    func getEvents() {
        var filterList: String? = nil
        if !filters.isEmpty {
            let nameList = filters.map({ String($0.id) })
            filterList = nameList.joined(separator: ",")
        }
        
        let request = EventRequest(pageStart: 0,
                                   limit: 15,
                                   filters: filterList)
        
        SGAlertUtility.showHUD()
        let eventSubject = SGEventService.getEvents(request: request)
        let walletSubject = SGWalletService.getWalletDetails()

        let combined = Publishers.Zip(eventSubject,
                                      walletSubject)
        
            combined.sink { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    SGAlertUtility.showErrorAlert(message: error.description)
                    break
                case .finished: break
                }
            } receiveValue: {[weak self] eventResponse, wallet in
                SGAlertUtility.hidHUD()
                self?.eventsFetched = true
                self?.events = eventResponse.result
                self?.totalCoins = wallet.silverCoins
                
                self?.connectSocketIfRequired()
            }
            .store(in: &cancellables)
    }
    
    func applyFilters(filters:[SGFilter]) {
        let sorted1 = self.filters.sorted(by: { $0.id < $1.id })
        let sorted2 = filters.sorted(by: { $0.id < $1.id })
                
        guard sorted1 != sorted2
        else { return }
        
        self.filters = sorted2
        
        //Clear previous results
        self.selectedIndex = 0
        self.events.removeAll()
        self.eventsFetched = false
        
        getEvents() //Refetch events
    }
    
    func bidEvent() {
        bidEvent(coins: Int(bidCoins), eventId: events[selectedIndex].id)
    }
    
    func bidEvent(coins: Int, eventId: Int) {
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
                self?.getEvents()
            }
            .store(in: &cancellables)
    }
    
    func getDetail(of event:Int) {
        SGAlertUtility.showHUD()
        SGEventService.getEvent(eventId: event)
            .sink { _ in
                SGAlertUtility.hidHUD()
            } receiveValue: {[weak self] output in
                let event = output.result
                
                guard let index = self?.events.firstIndex(where: { $0.id == event.id })
                else { return }
                
                self?.events[index] = event
            }
            .store(in: &cancellables)

    }
    
    //MARK: - Redirect flow handling
    func loadEvent(with id: Int) {
        if let index = events.firstIndex(where: { $0.id == id }) {
            self.selectedIndex = index
            return
        }
        
        SGAlertUtility.showHUD()
        SGEventService.getEvent(eventId: id)
            .sink { result in
                SGAlertUtility.hidHUD()
                switch result {
                case .failure(let error):
                    SGAlertUtility.showErrorAlert(message: error.localizedDescription)
                case .finished:
                    break
                }
                
            } receiveValue: {[weak self] result in
                self?.eventViewModel = SingleEventViewModel(event: result.result)
                self?.socketManager.startListening(events: [result.result])
            }
            .store(in: &cancellables)
    }
    
    func didExitFrom(event: Event) {
        guard !events.contains(where: { $0.id == event.id })
        else { return }
        
        socketManager.stopListening(events: [event])
    }
}

private extension EventListViewModel {
    func connectSocketIfRequired() {
        if !socketManager.isConnected {
            socketPublisher = socketManager.messageSubscriber
                .sink(receiveValue: {[weak self] message in
                    self?.handleSocketMessage(message)
                    self?.eventViewModel?.handleSocketMessage(message)
                })
            
            socketManager.connect(with: events)
        }
        else {
            socketManager.startListening(events: events)
        }
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
    
    func updateCounter(with info: EventCounterUpdate) {
        guard let eventIndex = events.firstIndex(where: { $0.id == info.eventID })
        else { return }
        
        var event = events[eventIndex]
        
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

        events[eventIndex] = event //Replacing with updated event
    }
    
    func updateProbability(with info: EventProbabilityUpdate) {
        guard let eventIndex = events.firstIndex(where: { $0.id == info.eventID })
        else { return }
        
        var event = events[eventIndex]
        event.probability = Int(info.probability)
        events[eventIndex] = event
    }
    
    func handleEventUpdate(with info: EventUpdate) {
        switch info.type {
        case .eventUpdate, .callStart:
            guard events.contains(where: { $0.id == info.eventID }) //Consider only those events which are part of the list
            else { return }
                        
//            getEvents()
            let eventID = info.eventID
            getDetail(of: eventID)
            
        case .eventDelete:
            guard let eventIndex = events.firstIndex(where: { $0.id == info.eventID })
            else { return }
            
            events.remove(at: eventIndex)
            
            if selectedIndex == eventIndex, selectedIndex > 0 {
                selectedIndex -= 1
            }
            else {
                selectedIndex = 0
            }
        }
    }
    
    func handleNotification() {
        getEvents()
    }
}

private extension EventListViewModel {
    func handleAppUpdate(type: AppUpdateType) {
        switch type {
        case .celebBlocked(let celebID):
            var currentEvents = events
            currentEvents.removeAll(where: { $0.celebId ==  celebID})
            
            self.events = currentEvents
            
        case .celebUnblocked(_): //To refresh
            self.selectedIndex = 0
            self.eventsFetched = false
            self.events.removeAll()
        }
    }
}
