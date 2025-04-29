//
//  SGFeedsRouter.swift
//  StarGaze
//
//  Created by Suraj Shetty on 01/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import UIKit

class SGFeedsRouter : SGRouter {
        
    enum Route: String {
        case filter
        case search
    }
    
    func route(to routeID: String, from context: UIViewController, parameters: Any?) {
        guard let route = Route(rawValue: routeID)
        else { return }
        
        switch route {
        case .filter:
            let vc = SGFeedsFilterViewController(nibName: "SGFeedsFilterViewController", bundle: nil)
            vc.datasource = (parameters as? [SGFilterHeaderViewModel]) ?? []
            vc.modalPresentationStyle = .fullScreen
            context.present(vc, animated: true)
                    
        default: break
        }
    }
}
