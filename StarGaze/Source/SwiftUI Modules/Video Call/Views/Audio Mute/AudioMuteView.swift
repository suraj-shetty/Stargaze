//
//  AudioMuteView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct AudioMuteView: View {
    @State var title: String
    @State var padding: EdgeInsets
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Text(title)
                .foregroundColor(.greyishBrown)
                .font(.system(size: 16, weight: .medium))
            
            Image("audioMuteIcon")
        }
        .padding(padding)
        .background(
            ZStack {
                Color.white
                    .opacity(0.92)
                    
                VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialLight))
            }
                .clipShape(Capsule())
        )
    }
}

struct AudioMuteView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                AudioMuteView(title: "Suraj",
                padding: EdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 12))
                
                Spacer()
            }
            
            Spacer()
        }
        .background(Color.darkText)
        
    }
}
