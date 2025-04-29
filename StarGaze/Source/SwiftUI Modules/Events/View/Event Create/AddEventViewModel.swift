//
//  AddEventViewModel.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import YPImagePicker
import SwiftDate

final class AddEventViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var date: Date? = Date()
    @Published var time: Date? = Date()
    @Published var winners: String = ""
    @Published var minPerWinners: String = ""
    @Published var coinsNumber: String = ""

    @Published var commentingOn = false
    @Published var eventCreated = false
    @Published var showImagePicker = false
    @Published var mediaItem: SGCreateFeedAttachment?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var eventType: EventType
    init(_ type: EventType) {
        self.eventType = type
    }
    
    var title: String {
        return eventType == .show ? "Create Show" : "Create Video Call"
    }
    
    var showWinnerFields: Bool {
        return eventType == .videoCall
    }
    
    var initialMediaItem: [YPMediaItem]? {
        guard let mediaItem = mediaItem else {
            return nil
        }
        return [mediaItem.item]
    }
}

// MARK: - Networking
extension AddEventViewModel {
    func uploadMediaAndCreateEvent() {
        guard let mediaItem = mediaItem else {
            SGAlertUtility.showErrorAlert(nil, message: "Please add image or video.")
            return
        }
        
        guard let date = date, let time = time else {
            SGAlertUtility.showErrorAlert(message: "Please pick the event date")
            return
        }
        
        guard let combineDate = combine(date: date, time: time) else {
            SGAlertUtility.showErrorAlert(message: "Please pick the event date")
            return
        }
        
        let minDate = Date() + 24.hours
        
        if combineDate < minDate {
            SGAlertUtility.showErrorAlert(message: "Event date needs to be atleast 24 hours from the current date & time")
            return
        }
        
        
        upload(item: mediaItem)
    }
    
    private func upload(item:SGCreateFeedAttachment) {
        let info = SGUploadInfo(type: .event,
                                url: item.fileURL!,
                                mimeType: item.mimeType)
        SGAlertUtility.showHUD()
        SGUploadManager.shared.upload(info: info)
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    SGAlertUtility.showErrorAlert(message: error.errorDescription)
                    break
                case .finished:
                    break
                }
            } receiveValue: {[weak self] value in
                item.uploadResponse = value
                self?.createEvent(with: item)
            }
            .store(in: &cancellables)
    }
    
    private func createEvent(with item: SGCreateFeedAttachment) {
        guard let date = date, let time = time else {
            SGAlertUtility.showErrorAlert(message: "Please pick the event date")
            return
        }
        
        guard let combineDate = combine(date: date, time: time) else { return }
        let callDuration = (Int(minPerWinners) ?? 0) * 60
        let request = EventCreateRequest(title: name,
                                         description: description,
                                         mediaPath: item.uploadResponse?.data.subPath ?? "",
                                         mediaType: item.mimeType.rawValue,
                                         winnersCount: Int(winners) ?? 0,
                                         minsPerWinner: callDuration,
                                         coins: Int(coinsNumber) ?? 0,
                                         startAt: combineDate.serverString,
                                         isCommentOn: !commentingOn)
        SGEventService.createEvent(with: request)
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
                SGAlertUtility.hidHUD()
                self?.eventCreated = true
            }
            .store(in: &cancellables)
    }
    
    private func combine(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var newComponents = DateComponents()
        newComponents.timeZone = .current
        newComponents.day = dateComponents.day
        newComponents.month = dateComponents.month
        newComponents.year = dateComponents.year
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        
        return calendar.date(from: newComponents)
    }
}
