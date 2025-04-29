//
//  NameInputViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 31/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class NameInputViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var isSaving: Bool = false
    @Published var error: SGAPIError? = nil
    @Published var didSave: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func validateAndSubmit() {
        do {
            let name = try validate()
            submit(name)
        }
        catch let error as SGAPIError {
            self.error = error
        }
        catch {
            self.error = SGAPIError.custom(error.localizedDescription)
        }
    }
    
    private func validate() throws -> String {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !name.isEmpty, name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SGAPIError.custom(NSLocalizedString("profile.edit.error.name", comment: ""))
        }
        
        return name
    }
    
    private func submit(_ name: String) {
        isSaving = true
        SGAlertUtility.showHUD()
        
        let request = EditProfileRequest(name: name, bio: nil, email: nil, picture: nil)
        SGUserService.updateProfile(with: request)
            .sink {[weak self] completion in
                switch completion {
                case .finished:  break
                case .failure(let error):
                    SGAlertUtility.hidHUD()
                    self?.error = error
                    self?.isSaving = false
                }
            } receiveValue: {[weak self] didSave in
                if !didSave {
                    SGAlertUtility.hidHUD()
                    
                    self?.isSaving = false
                    self?.error = SGAPIError.custom("Failed to save your name. Please try again.")
                }
                else {
                    self?.fetchUpdates()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchUpdates() {
        let profileSubject = SGUserService.getProfile()
        let walletSubject = SGWalletService.getWalletDetails()
        
        let combined = Publishers.Zip(profileSubject,
                                      walletSubject)
        isSaving = true
        combined.sink {[weak self] result in
            self?.isSaving = false
            
            switch result {
            case .finished: break
            case .failure(let failure):
                SGAlertUtility.hidHUD()
                self?.error = failure.id
            }
        } receiveValue: { detail, wallet in
            let session = SGAppSession.shared
            session.user.send(detail)
            session.wallet.send(wallet)
            
            SGUserDefaultStorage.saveUserData(user: detail)
            
            self.isSaving = false
            self.didSave = true
            SGAlertUtility.hidHUD()
        }
        .store(in: &cancellables)
    }
}
