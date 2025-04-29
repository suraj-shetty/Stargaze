//
//  CallToastView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 10/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct CallToastView: View {
    var title: String
    var icon: String
    
    init(title: String, icon: String) {
        self.title = title
        self.icon = icon
    }
        
    var body: some View {
        VStack(alignment: .center, spacing: 19) {
            Image(icon)
            
            Text(title)
                .foregroundColor(.darkText)
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: 120)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
        }
        .padding(EdgeInsets(top: 50, leading: 30, bottom: 33, trailing: 30))
        .background(
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialLight))
            }
                .clipShape(RoundedRectangle(cornerRadius: 25))
        )
    }
}

struct CallToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                CallToastView(title: "You’re Camera off",
                              icon: "audioMuteToastIcon")
                
                Spacer()
            }
            
            Spacer()
        }
        .background(Color.green)
    }
}
