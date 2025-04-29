//
//  VideoCallListCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 23/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher

struct EventHistoryRow: View {
    var viewModel: EventHistoryViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.profileInfoBackground
            
            GeometryReader { proxy in
                
                HStack(alignment: .center,
                       spacing: 16) {
                    
                    KFImage(viewModel.imageURL)
                        .resizable()
                        .fade(duration: 0.25)
                        .cancelOnDisappear(true)                        
                        .aspectRatio(contentMode: .fill)
                        .frame(width:proxy.size.height,
                               height: proxy.size.height)
                        .background(Color.brand1.opacity(0.8))
                        .clipped()
                    
                    VStack(alignment: .leading,
                           spacing: 5) {
                        Spacer()
                        
                        Text(viewModel.dateText)
                            .font(.system(size: 12,
                                          weight: .medium))
                            .foregroundColor(.text2)
                            .opacity(0.5)
                        
                        Text(viewModel.celebName)
                            .font(.system(size: 12,
                                          weight: .medium))
                            .foregroundColor(.maize1)
                            .opacity(colorScheme == .dark ? 0.5 : 1.0)
                        
                        Text(viewModel.title)
                            .font(.system(size: 16,
                                          weight: .regular))
                            .lineSpacing(6)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                       .padding(.trailing, 20)
            }
        }
        .cornerRadius(11)
        .frame(height: 118)
    }
}

struct VideoCallListCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EventHistoryRow(viewModel: .preview)
                .padding(.horizontal, 20)
            Spacer()
        }
    }
}
