//
//  ClearbackgroundModifier.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 14/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct ClearbackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        else {
            content.background(Color.clear)
        }
    }
}

extension View {
    func clearBackgroundStyle() -> some View {
        modifier( ClearbackgroundModifier() )
    }
}
