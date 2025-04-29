//
//  SideMenuViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

enum SideMenuState {
    case shown
    case animating
    case hidden
}

class SideMenuViewModel: ObservableObject {
    static let shared = SideMenuViewModel()
    
    @Published var showMenu: Bool = false
    @Published var state: SideMenuState = .hidden
}
