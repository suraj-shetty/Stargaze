//
//  ViewController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//

import UIKit

class ViewController: UIViewController {

    private let router = SGOnboardRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        if let navController = self.navigationController {
//            SGHelper.app.updateAppearance(of: navController)
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.pushNext()
        }
    }

    
    private func pushNext() {
        if let token = SGUserDefaultStorage.getToken(), let user = SGUserDefaultStorage.getUserData() {
            SGAppSession.shared.token = token
            SGAppSession.shared.user.send(user)
            
            router.route(to: SGOnboardRouter.Route.home.rawValue,
                         from: self,
                         parameters: nil)
        }
        else {
            router.route(to: SGOnboardRouter.Route.intro.rawValue,
                         from: self,
                         parameters: nil)
        }
    }
}

