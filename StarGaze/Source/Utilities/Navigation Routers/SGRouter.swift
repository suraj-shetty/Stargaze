//
//  SGRouter.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import UIKit

protocol SGRouter {
    func route(
          to routeID: String,
          from context: UIViewController,
          parameters: Any?
       )
}
