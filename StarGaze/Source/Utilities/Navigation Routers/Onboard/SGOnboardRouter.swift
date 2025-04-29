//
//  SGOnboardRouter.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class SGOnboardRouter : SGRouter {
        
    enum Route: String {
        case intro
        case signin
        case phoneInput
        case otp
        case home
    }
    
    func route(to routeID: String, from context: UIViewController, parameters: Any?) {
        guard let route = Route(rawValue: routeID)
        else { return }
        
        switch route {
        case .intro :
            let vc = SGAppIntroViewController(nibName: "SGAppIntroViewController", bundle: nil)
            vc.router = self
            context.navigationController?.pushViewController(vc, animated: true)

        case .signin:
            let vc = UIHostingController(rootView: SigninView())
            context.navigationController?.pushViewController(vc, animated: true)
            
        case .phoneInput:
            let vc = SGPhoneInputViewController(nibName: "SGPhoneInputViewController", bundle: nil)
            vc.router = self
            context.navigationController?.pushViewController(vc, animated: true)
            
        case .otp:
            guard let info = parameters as? SGOnboardViewModel
            else { fatalError("Invalid parameter received while loading OTP input") }
            
            let vc = SGPinInputViewController(nibName: "SGPinInputViewController", bundle: nil)
            vc.viewModel = info
            vc.router = self
            context.navigationController?.pushViewController(vc, animated: true)
            
        case .home:
            let homeVC = UIHostingController(rootView: SideMenuView())
            
            if let scene = UIApplication.shared.connectedScenes.first,
               let window = (scene as? UIWindowScene)?.keyWindow {
                window.set(rootViewController: homeVC,
                           options: .init(direction: .toRight,
                                          style: .easeOut)) { _ in
                }
            }
            
            
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            
//            if #available(iOS 13.0, *){
//
//                    if let scene = UIApplication.shared.connectedScenes.first{
//                        guard let windowScene = (scene as? UIWindowScene) else { return }
//                        print(">>> windowScene: \(windowScene)")
//
//                        if let window = windowScene.keyWindow, let vc = window.rootViewController {
//
//                            homeVC.view.frame = vc.view.frame
////                            homeVC.view.layoutIfNeeded()
//
//                            guard let currentSnapshot = window.snapshotView(afterScreenUpdates: true)
//                            else {
//                                window.rootViewController = homeVC
//                                window.makeKeyAndVisible()
//                                return
//                            }
//
//                            window.rootViewController = homeVC
//                            window.makeKeyAndVisible()
//
//                            window.addSubview(currentSnapshot)
//
//                            let width = homeVC.view.frame.width
//                            homeVC.view.transform = .init(translationX: width, y: 0)
//
//                            UIView.animate(withDuration: 0.25,
//                                           delay: 0,
//                                           options: .curveEaseOut) {
//                                currentSnapshot.transform = .init(translationX: -width, y: 0)
//                                homeVC.view.transform = .identity
//                            } completion: { _ in
//                                currentSnapshot.removeFromSuperview()
//                            }
//
//
//
////                            UIView.transition(with: window,
////                                              duration: 0.5,
////                                              options: .transitionCrossDissolve) {
////                                window.rootViewController = homeVC
////                                window.makeKeyAndVisible()
////                            } completion: { _ in
////
////                            }
//
//
//
////                            UIView.transition(with: window, duration: 0.5,
////                                              options: .transitionCrossDissolve,
////                                              animations: {
////                                            window.rootViewController = homeVC
////                                        }, completion: completion)
//
//
//                        }
//                        else {
//                            let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
//                            window.windowScene = windowScene //Make sure to do this
//                            window.rootViewController = homeVC
//                            window.makeKeyAndVisible()
//                        }
//
//
//
//
////                        appDelegate.window = window
//                    }
//                } else {
//                    appDelegate.window?.rootViewController = homeVC
//                    appDelegate.window?.makeKeyAndVisible()
//                }
            
            
        }
    }
}
