//
//  FaqViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 31/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

class FaqViewModel: ObservableObject {
    let title: String
    let info: String
    @Published var displayInfo: Bool = false
    
    init(title: String, info: String) {
        self.title = title
        self.info = info
    }
}
