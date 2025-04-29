//
//  SGCelebTileView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 19/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher

struct SGCelebTileView: View {
    @ObservedObject var viewModel: SGCelebrityViewModel
    
    var body: some View {
        VStack(alignment: .center,
               spacing: 15) {
            
            KFImage(viewModel.picURL)
                .resizable()
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .scaleFactor(UIScreen.main.scale)
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 71,
                                                                      height: 71))
                )
                .cacheOriginalImage()
                .aspectRatio(contentMode: .fill)
                .frame(width: 71, height: 71)
                .background(Color.text1.opacity(0.2))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.celebBrand,
                                lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2),
                        radius: 5,
                        x: 0, y: 3)
            
            Text(viewModel.name)
                .font(SwiftUI.Font.system(size: 13, weight: .regular, design: .default))
                .foregroundColor(.text2)
                .kerning(-0.3)
                .lineLimit(1)
//                .frame(width: .infinity)
        }
               .frame(width: 76)
    }
}

//struct SGCelebTileView_Previews: PreviewProvider {
//    static var previews: some View {
//        SGCelebTileView(viewModel: .preview)
//            .previewLayout(.fixed(width: 76, height: 103))
//            .preferredColorScheme(.dark)
//    }
//}
