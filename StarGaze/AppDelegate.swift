//
//  AppDelegate.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//

import UIKit
import FirebaseCore
import FirebaseDynamicLinks
import GoogleSignIn
import FacebookCore
import AuthenticationServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        Utility.logAllAvailableFonts()
        
        Settings.isAdvertiserIDCollectionEnabled = false
        Settings.isAutoLogAppEventsEnabled = false
        Settings.isSKAdNetworkReportEnabled = false
        Settings.setAdvertiserTrackingEnabled(false)
    
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application,
                                               didFinishLaunchingWithOptions: launchOptions)
        
        let keychain = KeyChainService()
        
        if let userID = keychain.appleUserID, !userID.isEmpty {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    break // The Apple ID credential is valid.
                case .revoked:
                    // The Apple ID credential is either revoked or was not found
                    keychain.deleteSavedAppleUserInfo()
                default:
                    break
                }
            }
        }
        
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            SGAppSession.shared.handleNotification(notification)
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            let handled = DynamicLinks.dynamicLinks()
                .handleUniversalLink(url) { dynamicLink, error in
                    if let link = dynamicLink {
                        print("Dynamic links: \(link)")
                    }
                    else if let error = error {
                        print("Dynamic links error: \(error)")
                    }
                }
            return handled
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey
                            .sourceApplication] as? String,
                           annotation: "")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            return true
        }
        
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        else if ApplicationDelegate.shared.application(application,
                                                       open: url,
                                                       sourceApplication: sourceApplication,
                                                       annotation: annotation) {
            return true
        }
        
        
        return false
    }
    
    //MARK: - APNS
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SGAppSession.shared.saveDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        return .newData
    }
}

