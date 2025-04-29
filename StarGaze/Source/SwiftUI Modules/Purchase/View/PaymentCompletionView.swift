//
//  PaymentCompletionView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 19/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

enum PaymentCompletionState: Int, Hashable {
    case success = 0
    case failure = 1
}

struct PaymentCompletionView: View {
    @State var state: PaymentCompletionState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 34) {
            Spacer()
            
            HStack {
                Spacer()
                Image((state == .success) ? "paymentSuccess" : "paymentFailure")
                Spacer()
            }
            
            VStack(alignment: .center,
                   spacing: 10) {
                Text((state == .success)
                     ? "payment.status.success.title"
                     : "payment.status.failure.title")
                .foregroundColor(.text1)
                .font(.system(size: 22,
                              weight: .medium))

                if state == .failure {
                    Text("payment.status.failure.desc")
                    .foregroundColor(.text1)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .multilineTextAlignment(.center)
                    .opacity(0.7)
                    .lineSpacing(6)
                }
                
//                Text((state == .success)
//                     ? "payment.status.success.desc"
//                     : "payment.status.failure.desc")
//                .foregroundColor(.text1)
//                .font(.system(size: 16,
//                              weight: .regular))
//                .multilineTextAlignment(.center)
//                .opacity(0.7)
//                .lineSpacing(6)
            }
            
            Spacer()
            
            if state == .failure {
                SGRoundRectButton(title: NSLocalizedString("payment.tryagain.title",
                                                           comment: ""),
                                  padding: 0) {
                    
                    let info = [NotificationUserInfoKey.paymentSuccess: false]                    
                    NotificationCenter.default.post(name: .exitPayment, object: nil, userInfo: info)
                }
                                  .padding(.bottom, 20)
            }
            else {
                Button {
                    
                    let info = [NotificationUserInfoKey.paymentSuccess: true]
                    NotificationCenter.default.post(name: .exitPayment, object: nil, userInfo: info)
                } label: {
                        Image("close")
                }
            }
        }
        .hiddenNavigationBarStyle()
        .padding(.horizontal, 20)
        .background(
            Color.brand1
                .ignoresSafeArea()
        )
    }
}

struct PaymentCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentCompletionView(state: .failure)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone SE (3rd generation)")
    }
}
