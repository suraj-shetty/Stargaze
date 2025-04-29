//
//  SceneDelegate.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//

import UIKit
import FacebookCore
import FirebaseCore
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if let response = connectionOptions.notificationResponse?.notification.request.content.userInfo {
            SGAppSession.shared.handleNotification(response)
        }
        else if let url = connectionOptions.userActivities.first?.webpageURL {
            DynamicLinks.dynamicLinks().handleUniversalLink(url) { link, error in
                guard let url = link?.url
                else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    SGAppSession.shared.handleShareLink(url)
                }
            }
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
//        if let user = SGUserDefaultStorage.getUserData() {
//            SGAppSession.shared.user = user
//            
//            let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = SGTabBarController(nibName: "SGTabBarController", bundle: nil)
//            self.window = window
//            window.makeKeyAndVisible()
//        }
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        ApplicationDelegate.shared.application(UIApplication.shared,
                                               open: url,
                                               sourceApplication: nil,
                                               annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL
        else { return }
        
        let dynamicLinks = DynamicLinks.dynamicLinks()
        if let link = dynamicLinks.dynamicLink(fromCustomSchemeURL: url) {
            if let url = link.url {
                SGAppSession.shared.handleShareLink(url)
            }
        }
        else {
            dynamicLinks.handleUniversalLink(url) { link, error in
                guard let url = link?.url
                else { return }
                
                SGAppSession.shared.handleShareLink(url)
            }
        }
    }
}

