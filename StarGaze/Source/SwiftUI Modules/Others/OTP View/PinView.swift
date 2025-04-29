//
//  PinView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 06/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Combine

struct PinView: View {
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    @Binding var otpCode: String
    var otpCodeLength: Int
    
    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                TextField("", text: $otpCode)
                    .textContentType(.oneTimeCode)
                    .font(Font.system(size: 29, weight: .medium))
                    .accentColor(.clear)
                    .foregroundColor(.clear)
                    .tint(.clear)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .onReceive(Just(otpCode)) { _ in limitText(otpCodeLength) }
                    .focused($focusedField, equals: .field)
                    .task {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            self.focusedField = .field
                        }
                    }
                    .padding()
                HStack(spacing: 18) {
                    ForEach(0..<otpCodeLength, id:\.self) { index in
                        ZStack {
                            Capsule()
                                .fill(Color.gold)
                                .frame(width: 53, height: 53)
                                .opacity(self.otpCode.count <= index ? 0.18 : 0.1)
                            
                            Text(self.getPin(at: index))
                                .font(Font.system(size: 29, weight: .medium))
                                .foregroundColor(.text1)
                                .frame(width: 53, height: 53)
                        }
                    }
                }
                .disabled(true)
            }
        }
    }
    
    //MARK: func
    private func getPin(at index: Int) -> String {
        guard self.otpCode.count > index else {
            return ""
        }
        return self.otpCode[index]
    }
    
    private func limitText(_ upper: Int) {
        if otpCode.count > upper {
            otpCode = String(otpCode.prefix(upper))
        }
    }

}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            
            PinView(otpCode: .constant("12"), otpCodeLength: 4)
            
            Spacer()
        }
    }
}
