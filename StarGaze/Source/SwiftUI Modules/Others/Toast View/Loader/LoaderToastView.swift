//
//  LoaderToastView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 02/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct LoaderToastView: View {
    @State var message: String
    
//    init(message: String) {
//        self.message = message
//    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                HStack(alignment: .center,
                       spacing: 10) {
                    ProgressView()
                        .tint(.darkText)
                    
                    Text(message)
                        .foregroundColor(.darkText)
                        .font(.system(size: 14,
                                      weight: .semibold))
                }
                       .frame(height: 20)
                       .padding(.vertical, 10)
                       .padding(.horizontal, 15)
                       .background(
                        Color.brand2
                            .clipShape(Capsule())
                       )
                
                Spacer()
            }            
            Spacer()
        }
    }
}

struct LoaderToastView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderToastView(message: "Loading")
    }
}
