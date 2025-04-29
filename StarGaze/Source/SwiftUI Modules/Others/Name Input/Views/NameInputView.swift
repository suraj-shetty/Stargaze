//
//  NameInputView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 31/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI

struct NameInputView: View {
    @FocusState private var isFocussed: Bool
    @StateObject private var viewModel = NameInputViewModel()
    @State private var showContent: Bool = false

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                .ignoresSafeArea()
                .opacity(showContent ? 1 : 0)
                .onTapGesture {
                    if isFocussed {
                        isFocussed = false
                    }
//                    else {
//                        //Dismiss
//                        withAnimation(.easeOut(duration: 0.25)) {
//                            showContent = false
//                        }
//
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                            withoutAnimation {
//                                self.dismiss()
//                            }
//                        }
//                    }
                }
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("profile.edit.card.title".localizedKey)
                        .foregroundColor(.text1)
                        .font(.system(size: 18,
                                      weight: .medium))
                    
                    SGTextField(title: NSLocalizedString("profile.edit.card.field.title", comment: ""),
                                placeHolder: NSLocalizedString("field.2.placeholder", comment: ""),
                                value: $viewModel.name,
                                keyboardType: .default,
                                borderColor: .textFieldBorder,
                                borderWidth: 1)
                    .focused($isFocussed)
                }
                
                SGRoundRectButton(title: NSLocalizedString("profile.edit.card.save",
                                                           comment: "")) {
                    isFocussed = false
                    viewModel.validateAndSubmit()
                }
            }
            .padding(.vertical, 20)
            .ignoresSafeArea(.keyboard,
                             edges: .bottom)
            .background(
                Color.brand1
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(.container,
                                     edges: .bottom)
            )
            .offset(x: 0, y: showContent ? 0 : 215) //215 is the input card view height. Change if UI gets updated.
        }
        .background(ClearBackgroundView()
            .ignoresSafeArea()
        )
        .onAppear(perform: {
            withAnimation(.spring()) {
                self.showContent = true
            }
        })
        .toast(item: $viewModel.error,
               dismissAfter: 5,
               onDismiss: nil,
               content: { error in
            SGErrorToastView(message: error.localizedDescription)
        })
        .onReceive(viewModel.$didSave) { output in
            if output == true {
                withAnimation(.easeOut(duration: 0.25)) {
                    showContent = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withoutAnimation {
                        self.dismiss()
                    }
                }
            }
        }
    }
}

struct NameInputView_Previews: PreviewProvider {
    static var previews: some View {
        NameInputView()
            .preferredColorScheme(.dark)
    }
}
