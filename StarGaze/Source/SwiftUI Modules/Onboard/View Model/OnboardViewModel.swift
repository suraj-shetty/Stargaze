//
//  OnboardViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 05/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import PhoneNumberKit
import CountryKit
import SwiftEmailValidator

enum OTPStatus {
    case unknown
    case duration(TimeInterval)
    case verified
}

@MainActor
class OnboardViewModel: ObservableObject {
    @Published var name: String = "" {
        didSet {
            if name != oldValue {
                updateInputState()
            }
        }
    }
    @Published var email: String = "" {
        didSet {
            if email != oldValue {
                updateInputState()
            }
        }
    }
    
    @Published var birthDate: Date? = nil
    @Published var country: Country? = nil {
        didSet {
            if country?.phoneCode != oldValue?.phoneCode {
                phoneInputDidChange()
            }
        }
    }
    
    @Published var phoneNumber: String = "" {
        didSet {
            if phoneNumber != oldValue {
                phoneInputDidChange()
            }
        }
    }
    @Published var otpStatus: OTPStatus = .unknown {
        didSet {
            updateInputState()
        }
    }
    @Published var didAgree: Bool = false {
        didSet {
            updateInputState()
        }
    }
    @Published var canSubmit: Bool = false
    @Published var otp: String = "" {
        didSet {
            otpTextDidChange()
            updateInputState()
        }
    }
    @Published var allowPinRequest: Bool = false
    @Published var loading: Bool = false
    @Published var didSignup: Bool = false
    
    private let apiService = SGOnboardService()
    private var autoRefreshTimer: DispatchSourceTimer?
    private var verifiedPin: String = ""
    
    init() {
        let countryKit = CountryKit()
        let currentCountry = countryKit.current ?? countryKit.searchByIsoCode("IN")
        
        if let country = currentCountry {
            self.country = country
        }
    }
    
    deinit {
        autoRefreshTimer?.cancel()
        autoRefreshTimer?.setEventHandler(handler: {})
    }
    
    func updateInputState() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasName = !name.isEmpty
        let hasEmail = !email.isEmpty
        let hasPhoneNumber = (country != nil) && !phoneNumber.isEmpty
        
        var didVerify: Bool = false
        switch otpStatus {
        case .verified:
            didVerify = true
            
        default:
            didVerify = false
        }
        
        let canSubmit = hasName && hasEmail && hasPhoneNumber && didVerify && didAgree
        self.canSubmit = canSubmit
    }
    
    func switchCountry(with code: String) {
        let countryKit = CountryKit()
        self.country = countryKit.searchByIsoCode(code)
    }
    
    func requestOTP() {
        guard let dialCode = country?.phoneCode
        else {
            SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.number", comment: ""))
            return
        }
        
        let internationalNumber = "\(dialCode)\(phoneNumber)"
        let phoneKit = PhoneNumberKit()
        
        do {
            _ = try phoneKit.parse(internationalNumber) //Validating phone number
        }
        catch {
            SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.number", comment: ""))
            return
        }
                                        
        loading = true

        Task {
            let request = SignInRequest(input: phoneNumber,
                                        countryCode: "\(dialCode)",
                                        type: .register,
                                        hashString: "")
            
            let result = await apiService.login(with: request)
            
            switch result {
            case .success(let success):
                let result = success.result
                
                if !result.isAccountPresent {
                    self.otpStatus = .duration(2*60)
                    self.allowPinRequest = false
                    self.runTimer()
                }
                else {
                    DispatchQueue.main.async {
                        SGAlertUtility.showErrorAlert(message: "Account exist with the provided mobile number. ")
                    }
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    SGAlertUtility.showErrorAlert(message: failure.localizedDescription)
                }
            }
            
            self.loading = false
        }
    }
    
    func verifyPin() {
        if !verifiedPin.isEmpty, verifiedPin == otp {
            return
        }
        
        loading = true
        Task {
            let request = VerifyRequest(input: phoneNumber,
                                        countryCode: "\(country?.phoneCode ?? 0)",
                                        pin: otp)
            let result = await apiService.verifySignupPin(with: request)
            switch result {
            case .success(_):
                self.stopTimer()
                self.otpStatus = .verified
                self.verifiedPin = self.otp

            case .failure(let failure):
                DispatchQueue.main.async {
                    SGAlertUtility.showErrorAlert(message: failure.localizedDescription)
                }
            }
            
            self.loading = false
        }
    }
    
    func onboard() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if name.isEmpty {
            SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.name", comment: ""))
            return
        }
        
        if email.isEmpty || !EmailSyntaxValidator.correctlyFormatted(email) {
            SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.email", comment: ""))
            return
        }
        
        switch otpStatus {
        case .verified: break
        default:
            SGAlertUtility.showErrorAlert(message: "Verify your mobile number")
            return
        }
        
        
        loading = true
        
        Task {
            let request = SignUpRequest(name: name,
                                        mobile: phoneNumber,
                                        email: email,
                                        code: "\(country?.phoneCode ?? 0)",
                                        birthDate: birthDate?.toFormat("yyyy-MM-dd"))
            let result = await apiService.signup(with: request)
            self.loading = false
            
            switch result {
            case .success(let success):
                let user = success.result
                self.saveDetail(user: user)
            case .failure(let failure):
                DispatchQueue.main.async {
                    SGAlertUtility.showErrorAlert(message: failure.localizedDescription)
                }
            }
        }
        
        
        
//        guard let dialCode = country?.phoneCode
//        else {
//            SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.number", comment: ""))
//            return
//        }
//
//        let internationalNumber = "\(dialCode)\(phoneNumber)"
//        let phoneKit = PhoneNumberKit()
//
//        do {
//            _ = try phoneKit.parse(internationalNumber) //Validating phone number
//        }
//        catch {
//            SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.number", comment: ""))
//            return
//        }
        
        
            /*
             if !name.isEmpty, name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                 throw SGAPIError.custom(NSLocalizedString("profile.edit.error.name", comment: ""))
             }
             
             if !bio.isEmpty, bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                 throw SGAPIError.custom(NSLocalizedString("profile.edit.error.bio", comment: ""))
             }

     //        if Int(countryCode) == nil || phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
     //            throw SGAPIError.custom(NSLocalizedString("profile.edit.error.number", comment: ""))
     //        }
             
             if !email.isEmpty, !EmailSyntaxValidator.correctlyFormatted(email) {
                 throw SGAPIError.custom(NSLocalizedString("profile.edit.error.email", comment: ""))
             }
             */
        
    }
}


private extension OnboardViewModel {
    func phoneInputDidChange() {
        otpStatus = .unknown
        stopTimer()
        updateInputState()
    }
    
    func runTimer() {
        if autoRefreshTimer?.isCancelled == false {
            stopTimer()
        }
        
        let queue = DispatchQueue.main
        autoRefreshTimer = DispatchSource.makeTimerSource(queue: queue)
        autoRefreshTimer?.schedule(deadline: .now(),
                                   repeating: .seconds(1))
        autoRefreshTimer?.setEventHandler(handler: {[weak self] in
            guard let ref = self
            else { return }
            
            switch ref.otpStatus {
            case .duration(let interval):
                let updatedInterval = interval - 1
                ref.otpStatus = .duration(updatedInterval)
                
                if updatedInterval <= 0 {
                    ref.allowPinRequest = true
                    ref.stopTimer()
                }
                break
                
            default: break
            }
        })
        
        autoRefreshTimer?.resume()
    }
    
    func stopTimer() {
        autoRefreshTimer?.cancel()
        autoRefreshTimer = nil
    }
    
    func otpTextDidChange() {
        if !verifiedPin.isEmpty {
            if verifiedPin == otp {
                otpStatus = .verified
            }
            else {
                otpStatus = .duration(0)
                allowPinRequest = true
            }
            updateInputState()
        }
        else {
            
        }
    }
    
    func saveDetail(user: UserDetail) {
        SGAppSession.shared.user.send(user)
        SGAppSession.shared.token = user.token
        
        SGUserDefaultStorage.saveUserData(user: user)
        SGUserDefaultStorage.saveToken(token: user.token)
    
        self.loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {[weak self] in
            self?.loading = false
            self?.didSignup = true
        }
    }
}
