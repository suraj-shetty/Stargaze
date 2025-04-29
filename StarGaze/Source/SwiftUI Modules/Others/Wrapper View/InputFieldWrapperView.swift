//
//  InputFieldWrapperView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 05/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct InputFieldWrapperView<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(title)
                .foregroundColor(.textFieldTitle)
                .font(.system(size: 14, weight: .medium))
                .frame(height: 16)
                .padding(.horizontal, 10)
                .background {
                    Color.brand1
                }
                .padding(.leading, 16)
                .zIndex(1)
            
            
            ZStack(alignment: .leading) {
                Text("")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.textFieldBorder)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                
                content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, 24)
                .background(Color.brand1)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                .padding(1)
            }
            .padding(.top, 9)

//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .padding(1)
//            .cornerRadius(10, corners: [.topLeft, .topRight])
//            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
        }
    }
}

struct InputFieldWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InputFieldWrapperView(title: "Name", content: {
                ZStack(alignment: .leading) {
                    Text("login.placeholder.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .opacity(0.2)
                    
                    TextField("", text: .constant(""))
                        .foregroundColor(.text1)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .tint(.text1)
    //                    .focused(viewModel.$inputFocussed)
    //                    .onSubmit {
    //                        viewModel.inputFocussed = false
    //                    }
                }
            })
            .frame(height: 76)
            
            Spacer()
        }
    }
}
