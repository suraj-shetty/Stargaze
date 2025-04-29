//
//  PaymentProcessingView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 29/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import StoreKit

struct PaymentProcessingView: View {
    @ObservedObject var store: Store
    @StateObject var paymentViewModel: PurchaseViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var paymentState: PaymentCompletionState?
    
    var body: some View {
        VStack(spacing: 34) {
            Spacer()
            
            HStack {
                Spacer()
                Image("paymentProcessing")
                Spacer()
            }
            
            VStack(alignment: .center,
                   spacing: 10) {
                Text("payment.status.process.title")
                .foregroundColor(.text1)
                .font(.system(size: 22,
                              weight: .medium))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(
            Color.brand1
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .navigationDestination(for: $paymentState) { state in
            PaymentCompletionView(state: state)
        }
        .onAppear {
            paymentViewModel.initiatePurchase()
        }
        .onReceive(paymentViewModel.$transaction) { output in
            if output != nil {
                Task {
                    await buy()
                }
            }
        }        
    }
    
    func buy() async {
        do {
            let transaction = try await store.purchase(paymentViewModel.product)
            let response = try await paymentViewModel.asyncCreditCoin(with: transaction)
            
            //Updating the wallet
            var wallet = SGAppSession.shared.wallet.value ?? Wallet(wildCoins: 0, silverCoins: 0)
            wallet.silverCoins = response.silverCoins
            wallet.goldCoins = response.goldCoins
            SGAppSession.shared.wallet.send(wallet)
            
            print("Payment was a success")
        
            await loadPaymentSuccess()
        }
        catch {
            print("Payment failed \(error)")
            await handleFailure()
        }
    }
    
    func handleFailure() async {
        if paymentViewModel.transaction != nil {
            _ = try? await paymentViewModel.asyncCancelTransaction()
            
            await loadPaymentFailure()
        }
        else {
            await loadPaymentFailure()
        }
    }
    
    @MainActor
    func loadPaymentSuccess() async {
        self.paymentState = .success
    }
    
    @MainActor
    func loadPaymentFailure() async {
        self.paymentState = .failure
    }
}

//struct PaymentProcessingView_Previews: PreviewProvider {
//    static var previews: some View {
//        PaymentSuccessView()
//    }
//}

//struct PaymentSuccessView: View {
//    var body: some View {
//        VStack {
//            SGNavigationView(title: "Payment Was Successful",
//                             isBackHidden: true)
//
//            TextBackgroundImageView(text: "It uses a dictionary of over Latin words, combined.",
//                                    image: "paymentSuccess", imagePaddingleft: 0, imagePaddingRight: 0)
//
//            Button {
//                // Close
//            } label: {
//                Image("close", bundle: nil)
//                    .resizable()
//                    .frame(width: 80, height: 80)
//            }
//
//            Spacer()
//
//        }
//        .background(Color.brand1)
//        .navigationBarHidden(true)
//    }
//}
