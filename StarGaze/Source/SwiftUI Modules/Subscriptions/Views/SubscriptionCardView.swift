//
//  SubscriptionCardView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 19/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct SubscriptionCardAppearance {
    let iconName: String
    let background: Gradient
    let shadow: Color
}

struct SubscriptionCardInfo {
    let title: String
    let cost: Int
    let features: [String]
}

struct SubscriptionCardView: View {
    let appearance: SubscriptionCardAppearance
    let info: SubscriptionCardInfo
    
    let onSelection: (()->())
    
    @State private var listHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(appearance.iconName)
            }
            .frame(width: 86, height: 86)
            .background(Color.brand1)
            .clipShape(Capsule())
            
            infoView()
                .padding(.top, 17)
            
            featureListView()
            
            Button {
                onSelection()
            } label: {
                Text("subscription.plan.choose.title")
                    .foregroundColor(.darkText)
                    .font(.system(size: 15, weight: .medium))
                    .kerning(-0.09)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.init(top: 30, leading: 35,
                                   bottom: 30, trailing: 35))
            }
        }
        .background(
            LinearGradient(gradient: appearance.background,
                           startPoint: .top,
                           endPoint: .bottom)
            .cornerRadius(11)
            .padding(.top, 43)
            .shadow(color: appearance.shadow,
                    radius: 11,
                    x: 0, y: 2)
        )
    }
    
    private func infoView() -> some View {
        VStack(spacing: 0) {
            Text(info.title)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .medium))
                .lineSpacing(2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
//                .minimumScaleFactor(0.5)
                .padding(.bottom, 20)
            
            Line()
                .stroke(Color.white.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1,
                                           dash: [5]))
                .frame(height: 1)
                .padding(.bottom, 16)
            
            Text("subscription.premium.title")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .regular))
                .kerning(-0.1)
            
            HStack(alignment: .bottom, spacing: 3) {
                Text("subscription.coins.title")
                    .foregroundColor(.white)
                    .font(.system(size: 11, weight: .regular))
                    .kerning(-0.08)
                
                Text("\(info.cost)")
                    .foregroundColor(.white)
                    .font(.system(size: 30, weight: .regular))
                    .frame(height: 19)
                
                Text("subscription.per.month.title")
                    .foregroundColor(.white)
                    .font(.system(size: 11, weight: .regular))
                    .kerning(-0.08)
            }
            .padding(.top, 13)
            .padding(.bottom, 21)
            
            Line()
                .stroke(Color.white.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1,
                                           dash: [5]))
                .frame(height: 1)
                .padding(.bottom, 14)
                
        }
        .padding(.horizontal, 35)
        
    }
    
    private func featureListView() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(info.features, id:\.self) { feature in
                    HStack(alignment: .top,
                           spacing: 10) {
                        Capsule()
                            .frame(width: 4, height: 4)
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .padding(.top, 7)

                        Text(feature)
                            .foregroundColor(.white)
                            .font(.system(size: 14,
                                          weight: .medium))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .readSize { size in
                listHeight = size.height
            }
        }
        .frame(maxHeight: listHeight)
        .padding(.horizontal, 38)
        
        
//        ScrollView {
//            VStack(alignment: .leading) {
//                ForEach(info.features, id:\.self) { feature in
//                    HStack(alignment: .center,
//                           spacing: 10) {
//                        Capsule()
//                            .frame(width: 4, height: 4)
//                            .foregroundColor(.text1)
//                            .opacity(0.5)
//
//                        Text(feature)
//                            .foregroundColor(.text1)
//                            .font(.system(size: 14,
//                                          weight: .medium))
//                            .lineSpacing(4)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                }
//            }
//        }
//        .fixedSize(horizontal: false, vertical: true)
//        .padding(.horizontal, 38)
//        .frame(height: .infinity)
//        .padding(.horizontal, 25)
    }
}

struct SubscriptionCardView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                
                SubscriptionCardView(
                    
                    appearance: SubscriptionCardAppearance(iconName: "appUnlockIcon",
                                                           background: Gradient(colors: [.coralPink, .fadedRed]),
                                                           shadow: .watermelon.opacity(0.44)),
                    info: SubscriptionCardInfo(title: "Unlock Complete App",
                                               cost: 500,
                                               features: [
                                                "Exclusive content",
                                                "Priority to win the video calls",
                                                "Ability to comment",
                                                "Message the stars privately",
                                                "Exclusive content",
                                                "Priority to win the video calls",
                                                "Ability to comment",
                                                "Message the stars privately",
                                                "Exclusive content",
                                                "Priority to win the video calls",
                                                "Ability to comment",
                                                "Message the stars privately",
                                               ]),
                    onSelection: {
                    }
                )
                .frame(width: 245)
                
                Spacer()
            }
            Spacer()
        }
        .background(Color.brand1
            .ignoresSafeArea())
        .preferredColorScheme(.light)
    }
    
}
