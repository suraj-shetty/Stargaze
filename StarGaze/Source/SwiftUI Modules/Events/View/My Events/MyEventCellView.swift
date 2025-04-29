//
//  MyEventCellView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 27/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher

struct MyEventCellView: View {
    @ObservedObject var viewModel: SGEventViewModel
    
    var body: some View {
        VStack(spacing: 17) {
            infoView()
        }
        .padding(.horizontal, 19)
        .padding(.top, 17)
        .padding(.bottom, 18)
        .background {
            Color.profileInfoBackground
                .cornerRadius(11)
        }
    }
    
    private func infoView() -> some View {
        HStack(alignment: .top, spacing: 10) {
            KFImage(viewModel.mediaURL)
                .resizable()
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .placeholder({
                    Color.text1.opacity(0.05)
                })
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 90)
                .cornerRadius(11)
            
            VStack(alignment: .leading,
                   spacing: 7) {
                Text(viewModel.title)
                    .foregroundColor(.text1)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .lineSpacing(6)
                
                Text(viewModel.dateText)
                    .foregroundColor(.text2)
                    .font(.system(size: 12,
                                  weight: .medium))
                    .opacity(0.5)
                
//                Spacer()
            }
        }
    }
    
    private func detailView() -> some View {
        HStack(alignment: .top,
               spacing: 0) {
            VStack(alignment: .leading,
                   spacing: 3) {
                
            }
        }
    }
}

struct MyEventCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            MyEventCellView(viewModel: .preview)
            
            Spacer()
        }
    }
}
