//
//  RectPreference.swift
//  StarGaze
//
//  Created by Suraj Shetty on 25/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

/// This PeferenceKey is used to pass a CGRect value from the child view to the parent view.
struct RectPreferenceKey: PreferenceKey
{
    typealias Value = CGRect

    static var defaultValue = CGRect.zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect)
    {
//        value = nextValue()
    }
}

extension View {
    func readFrame(space: CoordinateSpace, onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: RectPreferenceKey.self,
                                value: geometryProxy.frame(in: space))
            }
        )
            .onPreferenceChange(RectPreferenceKey.self, perform: onChange)
    }
}
