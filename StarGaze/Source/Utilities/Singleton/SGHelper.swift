//
//  SGHelper.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import UIKit

class SGHelper {
    static var app: SGHelper = {
        return SGHelper()
    }()
}


extension SGHelper {
    func updateAppearance(of navigationController:UINavigationController) {
        let backImage = UIImage(named: "navBack")
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backIndicatorImage  = backImage
        navAppearance.backIndicatorTransitionMaskImage = backImage
        navAppearance.backgroundColor = UIColor(named: "Brand1")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "Brand1")
        navigationController.navigationItem.standardAppearance = appearance
        navigationController.navigationItem.scrollEdgeAppearance = appearance
        
        navigationController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain,
                                                                                target: nil, action: nil)
        let navBar = navigationController.navigationBar
        navBar.barStyle = .black
        navBar.isTranslucent =  false
        navBar.titleTextAttributes  = [.foregroundColor : UIColor(named: "Text1")!,
                                       .font: SGFont(.installed(.GTWalsheimProMedium), size: .custom(18.0)).instance]
        navBar.tintColor = UIColor(named: "Text1")
        navBar.barTintColor = UIColor(named: "Brand1")
        navBar.backgroundColor = UIColor(named: "Brand1")
     
        navigationController.view.backgroundColor = UIColor(named: "Brand1")
    }
}
