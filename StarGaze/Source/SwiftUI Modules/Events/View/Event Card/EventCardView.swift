//
//  EventCardView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
struct EventCardView: View {
    @ObservedObject var event: SGEventViewModel
    
    @State private var imageDimension: CGFloat = 120
    
    var body: some View {
            VStack(alignment: .center,
               spacing: 20) {
            KFImage(event.mediaURL)
                .resizable()
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .aspectRatio(contentMode: .fill)
                .frame(width: imageDimension, height: imageDimension)
                .clipped()
                .background(Color.text1.opacity(0.2))
            
            VStack(alignment: .leading,
                   spacing: 6) {
                
                HStack(alignment: .center,
                spacing: 10) {
                    Text(event.dateText)
                        .font(.system(size: 15,
                                      weight: .regular))
                        .foregroundColor(.text2.opacity(0.6))
                        .frame(height: 24)
                    
                    Spacer()
                    
                    Image("multiple")
                        .renderingMode(.template)
                        .tint(.text2)
                        .opacity(0.2)
                        
                    Text("events.joined.count"
                        .formattedString(value: event.totalParticipants))
                        .font(.system(size: 15,
                                      weight: .regular))
                        .foregroundColor(.text2)
                        .frame(height: 24)
                }
                
                Text(event.title)
                    .font(.system(size: 23,
                                  weight: .medium))
                    .foregroundColor(.text1)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
            }
                   .padding([.horizontal, .bottom], 20)
        }
        .background(Color.eventCardBackground)
        .cornerRadius(12)
        .readSize { size in
            self.imageDimension = size.width
        }
    }
}

//struct EventCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            EventCardView(event: .preview)
//                .preferredColorScheme(.dark)
//            
//            Spacer()
//            Spacer()
//        }
//    }
//}
