//
//  SGBorderedButtonStyle.swift
//  StarGaze
//
//  Created by Suraj Shetty on 03/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct SGBorderedButtonStyle: ButtonStyle {
    var inset:EdgeInsets = EdgeInsets(top: 12, leading: 20, bottom: 13, trailing: 20)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.text1)
            .font(.walsheimRegular(size: 17))
//            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
            .padding(inset)
            .opacity(configuration.isPressed ? 0.3 : 1.0)
//            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .background(Capsule()
                .stroke(Color.brand2.opacity(configuration.isPressed ? 0.3 : 1.0),
                        lineWidth: 1))
    }
}
