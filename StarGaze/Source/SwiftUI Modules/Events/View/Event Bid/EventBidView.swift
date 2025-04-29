//
//  EventBidView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 29/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct EventBidView: View {
    @Binding var endOffsetY: CGFloat
    let action: () -> Void
    @Binding var coinNumber: Float
    @Binding var totalCoins: Int

    @State var startingOffsetY: CGFloat = UIScreen.main.bounds.height
    @State var currentOffsetY: CGFloat = 0
    
    @State private var loadEarnCoins: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                VStack(spacing: 15) {
                    Text("")
                        .frame(width: 60, height: 4)
                        .background(Color.text1.opacity(0.3))
                        .cornerRadius(2)
                        .padding()
                    Text("Bid on this Event & Increase the Winning Probability Chance!")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.walsheimMedium(size: 18))
                        .foregroundColor(.text1)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                    
                    Text("You can buy more tickets in order to increase the chances of your winning")
                        .font(.walsheimRegular(size: 15))
                        .foregroundColor(.text1.opacity(0.6))
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.center)
                    
                    Text("Available coins: \(Int(totalCoins))")
                        .font(.walsheimRegular(size: 17))
                        .foregroundColor(.brand2)
                    
                    SliderView(value: $coinNumber, minValue: 0, maxValue: Float(totalCoins))
                   
                    Button {
                        loadEarnCoins.toggle()
                    } label: {
                        Text("event.bid.earn.coins.title")
                            .foregroundColor(.brand2)
                            .font(.system(size: 18, weight: .medium))
                            .underline()
                            .frame(height: 24)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 5)
                    
                    SGRoundRectButton(title: NSLocalizedString("event.bid.place.title",
                                                               comment: ""),
                                      padding: 0) {
                        withAnimation(.spring()) {
                            endOffsetY = 0
                            currentOffsetY = 0
                            action()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
                .frame(maxWidth: .infinity)
                .background(Color.brand1)
                .cornerRadius(40)
                .padding(.bottom, -40)
            }
        }
        .background(Color.clear)
        .contentShape(Rectangle())
        .offset(y: startingOffsetY)
        .offset(y: currentOffsetY)
        .offset(y: endOffsetY)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    withAnimation(.spring()) {
                        currentOffsetY = value.translation.height
                    }
                })
            
                .onEnded({ value in
                    withAnimation(.spring()) {
                        if currentOffsetY < -150 {
                            layoutHeight()
                        } else if endOffsetY != 0 && currentOffsetY > 150 {
                            endOffsetY = 0
                        }
                        currentOffsetY = 0
                    }
                })
        )
        .fullScreenCover(isPresented: $loadEarnCoins) {
            EarnCoinsView()
        }
    }
    
    private func layoutHeight() {
        endOffsetY = -startingOffsetY
    }
}

struct EventBidView_Previews: PreviewProvider {
    static var previews: some View {
        EventBidView(endOffsetY: .constant(-UIScreen.main.bounds.height),
                     action: {
            
        },
                     coinNumber: .constant(100),
                     totalCoins: .constant(300))
//        EventBidView(bidNumber: .constant(9), endOffsetY: .constant(0), coinNumber: .constant(100))
    }
}

struct SliderView: View {
    @Binding var value: Float
    let minValue: Float
    let maxValue: Float
    
    var body: some View {
        ZStack {
            Slider(value: $value, in: minValue...maxValue, onEditingChanged: { _ in
                
            })
            .tint(.brand2)
            .padding()
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
            .background(Color.slate)
            .cornerRadius(6)
            .padding()
            
            Text("\(Int(value))")
                .foregroundColor(.brand2)
                .padding(.top, 32)
        }
    }
}
