//
//  NotifSettingsViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 04/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class NotifSettingsViewModel: ObservableObject {
    @PostPublished var settings: NotificationSettings = NotificationSettings()
    @Published var loading: Bool = false
    @Published var error: SGAPIError? = nil
    @Published var hasChanges: Bool = false
    @Published var changesSaved: Bool = false
    
    private var lastSettings: NotificationSettings? = nil
    private var changeObserver: AnyCancellable? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        lastSettings = settings
        changeObserver = $settings
            .sink(receiveValue: {[weak self] updated in
                let isSame = (updated == self?.lastSettings)
                self?.hasChanges = !isSame
            })
    }
    
    deinit {
        changeObserver?.cancel()
        cancellables.forEach({ $0.cancel() })
    }
    
    func fetchSettings() {
        loading = true
        
        NotificationService.getSettings()
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    self?.error = error
                    self?.loading = false
                }
            } receiveValue: { settings in
                self.lastSettings = settings
                self.settings.update(with: settings)
                self.loading = false
            }
            .store(in: &cancellables)
    }
    
    func saveChanges() {
        loading = true
        
        NotificationService.save(settings: self.settings)
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error) :
                    self?.error = error
                    self?.loading = false
                }
            } receiveValue: {[weak self] didSave in
                guard let ref = self else { return }
                
                if didSave {
                    ref.lastSettings?.update(with: ref.settings)
                    ref.hasChanges = false
                }
                                
                ref.changesSaved = didSave
                ref.loading = false
            }
            .store(in: &cancellables)
    }
}
