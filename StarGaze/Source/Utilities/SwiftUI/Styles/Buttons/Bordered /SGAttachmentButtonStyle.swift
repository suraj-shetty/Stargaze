//
//  SGAttachmentButtonStyle.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct SGAttachmentButtonStyle: ButtonStyle {    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.text1)
            .font(.walsheimRegular(size: 14))
        //            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 13, trailing: 20))
            .opacity(configuration.isPressed ? 0.3 : 1.0)
        //            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .background(Capsule()
                .stroke(Color.text1.opacity(0.1),
                        lineWidth: 1)
                    .opacity(configuration.isPressed ? 0.3 : 1.0)
            )
        
    }
}
