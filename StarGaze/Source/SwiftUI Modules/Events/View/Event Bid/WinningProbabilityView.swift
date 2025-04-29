//
//  WinningProbabilityView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 30/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct WinningProbabilityView: View {
    let winPercent: Int
    @State private var value: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            VStack {
                Text("Winning probability meter  (Open)")
                    .font(.walsheimRegular(size: 16))
                    .foregroundColor(.text1)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 4)
                
                Text("\(winPercent)% chances to win")
                    .font(.walsheimMedium(size: 12))
                    .foregroundColor(.text1.opacity(0.5))
                    .padding(.bottom, 21)
                
                ZStack {
                    Circle()
                        .stroke(Color.black, lineWidth: 10)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(winPercent)/100)
                        .stroke(Color.brand2, lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                        .overlay(
                            VStack {
                                Text("\(winPercent)%")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.text1)
                                Text("CHANCE\nTOWIN")
                                    .font(.system(size: 10))
                                    .foregroundColor(.text1)
                                    .multilineTextAlignment(.center)
                            }
                        )
                }
                .frame(width: 120, height: 120)
                .padding(.bottom, 30)

            }
            .frame(maxWidth: .infinity)
            .background(Color.slate1)
            .cornerRadius(10)
            .padding()
        }
        .background(Color.brand1)
        .onAppear {
            withAnimation {
                value = CGFloat(winPercent)/100
            }
        }
    }
}

struct WinningProbabilityView_Previews: PreviewProvider {
    static var previews: some View {
        WinningProbabilityView(winPercent: 80)
    }
}
