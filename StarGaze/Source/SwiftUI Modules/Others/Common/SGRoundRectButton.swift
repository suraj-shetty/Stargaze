//
//  SGRoundRectButton.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 29/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct SGRoundRectButton: View {
    let title: String
    var padding: CGFloat = 20
    var baseColor: Color = .brand2
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.darkText)
                .font(.system(size: 15, weight: .medium))
                .kerning(3.53)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(baseColor)
                .clipShape(Capsule())
                .padding(padding)
        }
    }
}
