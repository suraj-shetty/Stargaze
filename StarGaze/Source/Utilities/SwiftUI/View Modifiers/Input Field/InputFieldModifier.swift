//
//  InputFieldModifier.swift
//  StarGaze
//
//  Created by Suraj Shetty on 01/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct InputFieldModifier: ViewModifier {
    private var title:LocalizedStringKey!
    
    init(with title:LocalizedStringKey) {
        self.title = title
    }
    
 
    func body(content: Content) -> some View {        
        ZStack(alignment: .topLeading) {
            Text(title)
                .foregroundColor(.textFieldTitle
                    .opacity(0.9))
                .font(.system(size: 14,
                              weight: .medium))
                .padding(.horizontal, 8)
                .background(
                    Color.brand1
                )
                .offset(x: 11, y: 0)
                .zIndex(1)
            
            ZStack (alignment: .center) {
                Rectangle()
                    .fill(Color.textFieldBorder)
                    .frame(maxWidth: .infinity, minHeight: 68)
//                    .background(Color.blue)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                    
                Rectangle()
                    .fill(Color.brand1)
                    .frame(maxWidth: .infinity, minHeight: 68)
                    
//                    .background(Color.green)
                    .cornerRadius(9, corners: [.topLeft, .topRight])
                    .cornerRadius(23, corners: [.bottomLeft, .bottomRight])
                    .padding(1)
                
                
                content
                    .frame(maxWidth: .infinity, minHeight: 68)
                    .padding(.horizontal, 20)
//                    .padding(.trailing, 20)
//                    .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(Color.textFieldBorder,
//                                lineWidth: 1)
//                    )
                
            }
            .frame(height: 68)
            .padding(.top, 9)
            
                
//                .padding(<#T##edges: Edge.Set##Edge.Set#>, <#T##length: CGFloat?##CGFloat?#>)
//                .cornerRadius(16)
//                .cornerRadius(10, corners: [.topLeft, .topRight])
//                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
//                .border(Color.textFieldBorder,
//                        width: 1)
        }
    }
}

extension View {
    func inputFieldStyle(with title:LocalizedStringKey) -> some View {
        modifier( InputFieldModifier(with: title) )
    }
}
