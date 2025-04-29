//
//  ClearBackgroundView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 31/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI
struct ClearBackgroundView: UIViewRepresentable {
    
    private class EmptyBackgroundView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
        let view = EmptyBackgroundView() //Created a custon UIView, to resolved the flicker issue observed
        return view
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        
    }
}
