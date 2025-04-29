//
//  HiddenNavigationBar.swift
//  StarGaze
//
//  Created by Suraj Shetty on 01/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct HiddenNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
//        .navigationBarTitle("", displayMode: .inline)
        .navigationTitle(Text(""))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

extension View {
    func hiddenNavigationBarStyle() -> some View {
        modifier( HiddenNavigationBar() )
    }
}
