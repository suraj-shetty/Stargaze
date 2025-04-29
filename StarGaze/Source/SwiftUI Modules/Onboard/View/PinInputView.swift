//
//  PinInputView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 06/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct PinInputView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocussed: Bool
    
    @ObservedObject var viewModel: SigninViewModel
    @State private var pin: String = ""
    
    var body: some View {
        VStack(spacing:0) {
            navView()
            
            Text("Please enter the OTP received on your registered mobile number")
                .foregroundColor(.text1)
                .font(.system(size: 16, weight: .regular))
                .lineSpacing(6)
                .opacity(0.5)
                .multilineTextAlignment(.center)
                .frame(width: 300)
            
            Color.clear
                .frame(height: 74)
            
            PinView(otpCode: $pin, otpCodeLength: 4)
                .focused($isFocussed)
                .onChange(of: pin) { newValue in
                    if newValue.count == 4 {
                        self.isFocussed = false
                    }
                }
                .onTapGesture {
                    self.isFocussed = true
                }
            
            Spacer()
            
            Button {
                viewModel.login()
            } label: {
                Text("Send me a new code")
                    .foregroundColor(.gold)
                    .font(.system(size: 18, weight: .medium))
            }
            .frame(height: 60)
            
            SGRoundRectButton(title: "VERIFY") {
                viewModel.verify(with: pin)
            }
            .disabled(pin.count < 4)
            .opacity(pin.count < 4 ? 0.5 : 1.0)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button {
                    self.isFocussed = false
                } label: {
                    Text("Done")
                        .foregroundColor(.text1)
                        .font(.system(size: 15, weight: .regular))
                }
            }
        }
        .background {
            Color.profileInfoBackground
                .ignoresSafeArea()
        }
    }
    
    private func navView() -> some View {
        HStack(alignment: .center) {
            Color.clear
                .frame(width: 64, height: 64)
                                    
            Spacer()
            
            Text("Enter OTP")
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image("subscriptionClose")
                    .tint(.text1)
                    
            }
            .frame(width: 64, height: 64)
        }
    }
}

struct PinInputView_Previews: PreviewProvider {
    static var previews: some View {
        PinInputView(viewModel: SigninViewModel())
    }
}
