//
//  OverlayView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct OverlayView: View {
    @State var info:SGOverlayInfo
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            
            VStack(alignment: .center, spacing: 20) {
                Image(info.icon)
                
                VStack(alignment: .center, spacing: 12) {
                    Text(info.title)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                    
                    if let message = info.message, !message.isEmpty {
                        Text(message)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 28)
            
            Spacer()
        }
        .background(.regularMaterial)
        .preferredColorScheme(.dark) //To set blur shade
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            OverlayView(info: SGOverlayInfo(title: "Poor Connection",
                                            icon: "radio",
                                            message: "The video will resume automatically when the connection improves."))
        }
        .background(Color.red)
    }
}
