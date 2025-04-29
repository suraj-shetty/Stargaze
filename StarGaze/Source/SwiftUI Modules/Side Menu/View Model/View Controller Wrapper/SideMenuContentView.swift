//
//  SideMenuContentView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct SideMenuContentView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    private(set) var controller: UIViewController
//    @EnvironmentObject var menuViewModel: SideMenuViewModel
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        controller.view.layoutIfNeeded()
        controller.view.setNeedsDisplay()
    }
    
//    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
//        uiViewController.willMove(toParent: nil)
//        uiViewController.view.removeFromSuperview()
//        uiViewController.removeFromParent()
//        uiViewController.didMove(toParent: nil)
//    }
}
