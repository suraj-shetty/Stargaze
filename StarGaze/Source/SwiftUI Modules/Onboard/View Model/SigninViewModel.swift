//
//  SigninViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI
import CountryKit
import PhoneNumberKit
import SwiftEmailValidator
import GoogleSignIn
import FirebaseCore
import FacebookLogin
import AuthenticationServices
import FirebaseAuth
import CryptoKit

@MainActor
class SigninViewModel: ObservableObject {
    @Published var input: String = "" {
        didSet {
            if input != oldValue {
                checkInputType()
            }
        }
    }
    
    @Published var isMobileNumber: Bool = false
    @Published var country: Country? = nil {
        didSet {
            if country?.phoneCode != oldValue?.phoneCode {
                phoneInputDidChange()
            }
        }
    }
    
    @FocusState var inputFocussed: Bool
    @Published var captureOTP: Bool = false
    @Published var loading: Bool = false
    @Published var didLogin: Bool = false

    @Published var phoneNumber: String = ""{
        didSet {
            if phoneNumber != oldValue {
                phoneInputDidChange()
            }
        }
    }
    
    @Published var otp: String = "" {
        didSet {
            otpTextDidChange()
            updateInputState()
        }
    }
    
    @Published var allowPinRequest: Bool = false
    
    @Published var canSubmit: Bool = false
    @Published var otpStatus: OTPStatus = .unknown {
        didSet {
            updateInputState()
        }
    }
    @Published var capturePhoneNumber: Bool = false
    
    private var autoRefreshTimer: DispatchSourceTimer?
    private var verifiedPin: String = ""    
    
    private let apiService = SGOnboardService()
    private var appleLoginProxy: AppleLoginProxy? = nil
    
    private var socialLoginRequest:SocialSignInRequest? = nil
    fileprivate var currentNonce: String?
    
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
    
    func switchCountry(with code: String) {
        let countryKit = CountryKit()
        self.country = countryKit.searchByIsoCode(code)
    }
    
    func login() {
        if !isMobileNumber {
            if !input.isEmpty, !EmailSyntaxValidator.correctlyFormatted(input) {
                SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.email", comment: ""))
                return
            }
        }
        else {
            guard let dialCode = country?.phoneCode
            else {
                SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.number", comment: ""))
                return
            }
            
            let internationalNumber = "\(dialCode)\(input)"
            let phoneKit = PhoneNumberKit()
            
            do {
                _ = try phoneKit.parse(internationalNumber) //Validating phone number
            }
            catch {
                SGAlertUtility.showErrorAlert(message: NSLocalizedString("profile.edit.error.number", comment: ""))
                return
            }
        }            
        
        loading = true
        Task {
            let request = SignInRequest(input: input.lowercased(),
                                        countryCode: isMobileNumber
                                        ? "\(country?.phoneCode ?? 0)"
                                        : nil,
                                        type: .login,
                                        hashString: "")
            
            let loginResult = await apiService.login(with: request)
            
            switch loginResult {
            case .success(let success):
                let result = success.result
                
                if result.isAccountPresent {
                    self.captureOTP = true
                }
                else {
                    DispatchQueue.main.async {
                        SGAlertUtility.showErrorAlert(message: "User doesn't exist for the provided email address/mobile number")
                    }
                }
                
            case .failure(let failure):
                DispatchQueue.main.async {
                    SGAlertUtility.showErrorAlert(message: failure.localizedDescription)
                }
            }
            
            self.loading = false
        }
        
//        self.captureOTP = true
    }
    
    func verify(with otp:String) {        
        loading = true
        
        Task {
            let request = VerifyRequest(input: input.lowercased(),
                                        countryCode: isMobileNumber
                                        ? "\(country?.phoneCode ?? 0)"
                                        : nil,
                                        pin: otp)
            let result = await apiService.verifyPin(with: request)
            self.loading = false
            
            switch result {
            case .success(let success):
                let user = success.result
                self.saveDetail(user: user)
                self.didLogin = true
                
            case .failure(let failure):
                DispatchQueue.main.async {
                    SGAlertUtility.showErrorAlert(message: failure.localizedDescription)
                }
            }
        }
    }
    
    
}

extension SigninViewModel { //Social N/w auth
    func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID
        else { return }
        
        guard let vc = UIApplication.shared.keyWindow?.rootViewController
        else { return }
        
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config,
                                        presenting: vc) {[weak self] user, error in
            if let error = error {
                SGAlertUtility.showErrorAlert(message: error.localizedDescription)
            }
            else if let authentication = user?.authentication,
                    let idToken = authentication.idToken,
                    let profile = user?.profile {
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                self?.firebaseAuth(with: credential,
                                   name: profile.name,
                                   type: .google)
                GIDSignIn.sharedInstance.signOut()
            }
//            else if let user = user, let id = user.userID, let profile = user.profile {
//                let request = SocialSignInRequest(id: id,
//                                                  type: .google,
//                                                  name: profile.name,
//                                                  email: profile.email)
//                self?.socialLogin(with: request)
//
//                GIDSignIn.sharedInstance.signOut()
//            }
            else {
                SGAlertUtility.showErrorAlert(message: "User data is missing")
            }
        }
    }
    
    func facebookLogin() {
        guard let vc = UIApplication.shared.keyWindow?.rootViewController
        else { return }
        
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile", "email"],
                      from: vc) {[weak self] result, error in
            if let error = error {
                SGAlertUtility.showErrorAlert(message: error.localizedDescription)
            }
            else if let result = result {
                if result.isCancelled {
                    //Do nothing
                    SGAlertUtility.showErrorAlert(message: "The user canceled the sign-in flow.")
                }
                else {
                    self?.loading = true
                    Profile.loadCurrentProfile { profile, error in
                        self?.loading = false
                        
                        if let error = error {
                            SGAlertUtility.showErrorAlert(message: error.localizedDescription)
                        }
                        else if let profile = profile, let token = AccessToken.current?.tokenString {
                            
                            let fbAuth = FacebookAuthProvider.credential(withAccessToken: token)
                            self?.firebaseAuth(with: fbAuth,
                                               name: profile.name ?? "",
                                               type: .facebook)
//                            let request = SocialSignInRequest(id: profile.userID,
//                                                              type: .facebook,
//                                                              name: profile.name ?? "",
//                                                              email: profile.email ?? "")
//                            self?.socialLogin(with: request)
                            manager.logOut()
                        }
                    }
                }
            }
        }
    }
    
    func appleLogin() {
//        guard let vc = UIApplication.shared.keyWindow?.rootViewController
//        else { return }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
        
        let loginProxy = AppleLoginProxy()
        loginProxy.callback = {[weak self] credential in
            
            guard let nonce = self?.currentNonce else {
                return
                //                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = credential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let authCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
            
            var name = credential.fullName?.formatted() ?? ""
            var email = credential.email ?? ""
            let keychain = KeyChainService()
            
            if !name.isEmpty, !email.isEmpty {
                keychain.saveAppleUserName(name: name)
                keychain.saveAppleEmail(email: email)
                keychain.saveAppleUserID(userID: credential.user)
            }
            else {
                name = keychain.appleUserName ?? ""
                email = keychain.appleUserEmail ?? ""
            }
            
            self?.firebaseAuth(with: authCredential,
                               name: name,
                               type: .apple)
            
//            let request = SocialSignInRequest(id: credential.user,
//                                              type: .apple,
//                                              name: name,
//                                              email: email)
//            self?.socialLogin(with: request)
            self?.appleLoginProxy = nil
        }
        
        self.appleLoginProxy = loginProxy
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = loginProxy
        authController.performRequests()
//        authController.presentationContextProvider  =
    }
    
    private func firebaseAuth(with credential: AuthCredential,
                              name: String,
                              type: SocialSignInRequest.SocialSignType
    ) {
        loading = true
        
        Auth.auth().signIn(with: credential) {[weak self] result, error in
            self?.loading = false
            if let error = error {
                SGAlertUtility.showErrorAlert(message: error.localizedDescription)
            }
            else if let result = result {
                let user = result.user
                let email = user.email
                let uid = user.uid
                
                let request = SocialSignInRequest(id: uid,
                                                  type: type,
                                                  name: name,
                                                  email: email ?? "")
                self?.socialLogin(with: request)
                GIDSignIn.sharedInstance.signOut()
                
                do {
                    try Auth.auth().signOut()
                }
                catch {
                    
                }
                
            }
        }
        
        /*
         Auth.auth().signIn(with: credential) { authResult, error in
             if let error = error {
               let authError = error as NSError
               if isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                 // The user is a multi-factor user. Second factor challenge is required.
                 let resolver = authError
                   .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                 var displayNameString = ""
                 for tmpFactorInfo in resolver.hints {
                   displayNameString += tmpFactorInfo.displayName ?? ""
                   displayNameString += " "
                 }
                 self.showTextInputPrompt(
                   withMessage: "Select factor to sign in\n\(displayNameString)",
                   completionBlock: { userPressedOK, displayName in
                     var selectedHint: PhoneMultiFactorInfo?
                     for tmpFactorInfo in resolver.hints {
                       if displayName == tmpFactorInfo.displayName {
                         selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                       }
                     }
                     PhoneAuthProvider.provider()
                       .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                          multiFactorSession: resolver
                                            .session) { verificationID, error in
                         if error != nil {
                           print(
                             "Multi factor start sign in failed. Error: \(error.debugDescription)"
                           )
                         } else {
                           self.showTextInputPrompt(
                             withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                             completionBlock: { userPressedOK, verificationCode in
                               let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                 .credential(withVerificationID: verificationID!,
                                             verificationCode: verificationCode!)
                               let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                 .assertion(with: credential!)
                               resolver.resolveSignIn(with: assertion!) { authResult, error in
                                 if error != nil {
                                   print(
                                     "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                   )
                                 } else {
                                   self.navigationController?.popViewController(animated: true)
                                 }
                               }
                             }
                           )
                         }
                       }
                   }
                 )
               } else {
                 self.showMessagePrompt(error.localizedDescription)
                 return
               }
               // ...
               return
             }
             // User is signed in
             // ...
         }
         */
    }
    
    private func socialLogin(with request: SocialSignInRequest) {
        if request.name.isEmpty || request.email.isEmpty {
            SGAlertUtility.showErrorAlert(message: "Unable to login since name/email address is empty.")
            return
        }
                
        loading = true
        
        Task {
            let result = await apiService.socialSignin(with: request)
            self.loading = false
            
            switch result {
            case .success(let success):
                let user = success.result
                
                let mobileNumber = user.mobileNumber
                let dialCode = user.dialCode ?? "0"
                
                if mobileNumber == "0" || dialCode == "0" {
                    self.socialLoginRequest = request
                    self.capturePhoneNumber = true
                }
                else {
                    self.saveDetail(user: user)
                    self.didLogin = true
                }
                
            case .failure(let failure):
                DispatchQueue.main.async {
                    SGAlertUtility.showErrorAlert(message: failure.localizedDescription)
                }
            }
        }
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
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
        
    func updateInputState() {
        let hasPhoneNumber = (country != nil) && !phoneNumber.isEmpty
        
        var didVerify: Bool = false
        switch otpStatus {
        case .verified:
            didVerify = true
            
        default:
            didVerify = false
        }
        
        let canSubmit = hasPhoneNumber && didVerify
        self.canSubmit = canSubmit
    }
    
    func saveMobileNumber() {
        guard let socialRequest = socialLoginRequest
        else { return }

        loading = true
        
        Task {
            let request = PhoneUpdateRequest(type: socialRequest.type,
                                             id: socialRequest.id,
                                             number: phoneNumber,
                                             dialCode: "\(country?.phoneCode ?? 0)")
            
            let result = await apiService.update(with: request)
            
            self.loading = false
            
            switch result {
            case .success(let success):
                let user = success.result
                self.saveDetail(user: user)
                self.didLogin = true
                
            case .failure(let failure):
                DispatchQueue.main.async {
                    SGAlertUtility.showErrorAlert(message: failure.localizedDescription)
                }
            }
        }
    }
}

private extension SigninViewModel {
    func checkInputType() { //Checking whether input is either email address or mobile number
        let inputText = input
        guard !inputText.isEmpty
        else { //If empty string, hide country code region
            isMobileNumber = false
            return
        }
        
        let nonDigitString = inputText
            .components(separatedBy: .decimalDigits)
            .joined()
        
        isMobileNumber = nonDigitString.isEmpty
        
        //If 10 digits are entered and is a phone number
        if nonDigitString.isEmpty, inputText.count == 10 {
//            self.inputFocussed = false
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func saveDetail(user: UserDetail) {
        SGAppSession.shared.user.send(user)
        SGAppSession.shared.token = user.token
        
        SGUserDefaultStorage.saveUserData(user: user)
        SGUserDefaultStorage.saveToken(token: user.token)
    }
}

//extension SigninViewModel: ASAuthorizationControllerDelegate {
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        <#code#>
//    }
//}


class AppleLoginProxy: NSObject, ASAuthorizationControllerDelegate {
    var callback: ((ASAuthorizationAppleIDCredential) ->())? = nil
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            self.callback?(appleIDCredential)
                        
        default: break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        var message = ""
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled: message = "The user canceled the the sign-in flow."
            case .failed: message = "Failed to authorise the login."
            default: message = authError.localizedDescription
            }
        }
        else {
            message = error.localizedDescription
        }
        
        SGAlertUtility.showErrorAlert(message: message)
    }
}

private extension SigninViewModel {
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
}
