//
//  KeyChainService.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 08/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

/// A Helper class which abstract Keychain API related calls.
final class KeyChainService {
    // MARK: - Properties
    static let shared = KeyChainService()
    
    /// Returns previous saved user name if available.
    var appleUserName: String? {
        return KeychainWrapper
            .standard
            .string(forKey: .appAppleUserName)
    }
    
    /// Returns previous saved user appleId/email  if available.
    var appleUserEmail: String? {
        return KeychainWrapper
            .standard
            .string(forKey: .appAppleEmailId)
    }
    
    var appleUserID: String? {
        return KeychainWrapper
            .standard
            .string(forKey: .appAppleUserId)
    }
    
    /// Saves the apple user name into keychain.
    /// - Parameter name: Apple user name retrieved form AppleLogin.
    /// - Returns: true if succeed otherwise false.
    @discardableResult
    func saveAppleUserName(name: String?) -> Bool {
        guard let name = name else {return false}
        return KeychainWrapper.standard.set(
            name,
            forKey: KeychainWrapper.Key.appAppleUserName.rawValue
        )
    }
    
    /// Saves the apple user email into keychain.
    /// - Parameter email: Apple userId/email  retrieved form AppleLogin.
    /// - Returns: true if succeed otherwise false.
    @discardableResult
    func saveAppleEmail(email: String?) -> Bool {
        guard let email = email else {return false}
        return KeychainWrapper.standard.set(
            email,
            forKey: KeychainWrapper.Key.appAppleEmailId.rawValue
        )
    }
    
    @discardableResult
    func saveAppleUserID(userID: String?) -> Bool {
        guard let userID = userID else {return false}
        return KeychainWrapper.standard.set(
            userID,
            forKey: KeychainWrapper.Key.appAppleUserId.rawValue
        )
    }

    /// Deletes both apple user name and saved Id from keyChain.
    func deleteSavedAppleUserInfo(){
        KeychainWrapper.standard.remove(forKey: .appAppleUserName)
        KeychainWrapper.standard.remove(forKey: .appAppleEmailId)
        KeychainWrapper.standard.remove(forKey: .appAppleUserId)
    }
}

// MARK: - KeychainWrapper + Extensions
extension KeychainWrapper.Key {
    /// A random string used to identify saved user apple name from keychain.
    static let appAppleUserName: KeychainWrapper.Key = "appAppleUserName"
    
    /// A random string used to identify saved user apple email /Id from keychain.
    static let appAppleEmailId:KeychainWrapper.Key = "appAppleEmailId"
    
    static let appAppleUserId:KeychainWrapper.Key = "appAppleUserId"
}
