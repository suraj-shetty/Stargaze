//
//  FaqCellView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 31/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct FaqCellView: View {
    @ObservedObject var viewModel: FaqViewModel
    var body: some View {
        VStack(alignment: .leading,
               spacing: 0) {
            HStack(alignment: .center,
                   spacing: 0) {
                Text(viewModel.title)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .foregroundColor(.text1)
                    .lineSpacing(6)
                
                Spacer()
                
                Button {
                    
                } label: {
                    ZStack {
                        Text(viewModel.displayInfo ? "-" : "+")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .regular))
                            .lineSpacing(8)
                    }
                }
                .frame(width: 30, height: 30, alignment: .center)
                .background {
                    showHideBackground()
                }
                .clipShape(Capsule())

            }
            
            if viewModel.displayInfo {
                Text(viewModel.info)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.text2)
                    .lineSpacing(10)
                    .multilineTextAlignment(.leading)
                    .opacity(0.59)
                    .padding(.top, 18)
                    .padding(.bottom, 14)
            }
            else {
                Text("")
                    .frame(height: 24)
            }
            
            Spacer()
            
            Divider()
                .foregroundColor(.tableSeparator)
                .frame(height: 1)
                
        }
               .padding(EdgeInsets(top: 20,
                                   leading: 20,
                                   bottom: 24,
                                   trailing: 20))
    }
    
    @ViewBuilder
    private func showHideBackground() -> some View {
        if viewModel.displayInfo {
            Color.brownGrey
        }
        else {
            Color.celebBrand
        }
    }
}

struct FaqCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
//            Spacer()
            
            FaqCellView(viewModel: FaqViewModel(title: "A title",
                                                info: "Yes you can earn free coins under the home events tab and choose the “Earn free coins” option. After that you will be asked to either watch a video or invite friends or share on other social networks or follow Stargaze on the other social media platforms."))
            Spacer()
        }
        .padding()
        .background {
            Color.brand1
        }
    }
}
