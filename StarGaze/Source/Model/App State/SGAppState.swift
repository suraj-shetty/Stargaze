//
//  SGAppState.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class AppState: NSObject, ObservableObject {
    @Published var videoMuted: Bool = false
    
    static let shared = AppState()
}
