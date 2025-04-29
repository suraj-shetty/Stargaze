//
//  PlaceholderView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 29/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct PlaceholderView: View {
    var info: PlaceholderInfo!
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .center,
                   spacing: 30) {
                Spacer()
                
                Image(info.image)
                    .aspectRatio(contentMode: .fit)
                
                VStack(alignment: .center,
                       spacing: 10) {
                    Text(info.title)
                        .foregroundColor(.text1)
                        .font(.system(size: 22, weight: .medium))
                        .frame(height:25)
                    
                         Text(info.message)
                        .foregroundColor(.text1)
                        .font(.system(size: 16, weight: .regular))
                        .lineSpacing(6)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            
            Spacer()
        }
//               .listRowInsets(.init())
//               .listRowBackground(Color.brand1)
//               .listRowSeparator(.hidden)
//               .padding(.horizontal, 25)
//               .frame(maxWidth:UIScreen.main.bounds.width,
//                      minHeight:self.placeholderHeight,
//                      maxHeight:self.placeholderHeight)
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                              title: "NO_FEED_TITLE".localizedKey,
                                              message: "NO_FEED_DESC".localizedKey))
    }
}
