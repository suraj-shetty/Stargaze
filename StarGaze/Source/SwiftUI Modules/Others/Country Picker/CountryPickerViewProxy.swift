//
//  CountryPickerViewProxy.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 06/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import SwiftUI
import CountryPicker

struct CountryPickerViewProxy: UIViewControllerRepresentable {
    
    let onSelect: (( _ choosenCountry: Country) -> Void)?
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: CountryPickerController.create {
            onSelect?($0)}
        )
    }
}
