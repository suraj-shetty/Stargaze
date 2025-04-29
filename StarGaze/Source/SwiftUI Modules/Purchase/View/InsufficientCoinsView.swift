//
//  InsufficientCoinsView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 28/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct InsufficientCoinsView: View {
    var body: some View {
        NavigationView {
            VStack {
                SGNavigationView(title: "Insufficient Coins!")
                    .frame(height: 44)
                    .padding(.horizontal, 12)
                
                Text("Oh no! Looks like you can’t join this event because of insuficient coins..")
                    .font(.walsheimRegular(size: 16))
                    .foregroundColor(.text1.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 45)
                
                Spacer()
                
                Image("insufficientFunds", bundle: nil)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 56)
                    .padding(.vertical, 20)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                
                NavigationLink {
                    BuyCoinsView()
                        .hiddenNavigationBarStyle()
                } label: {
                    Text("BUY COINS")
                        .foregroundColor(.darkText)
                        .font(.system(size: 15, weight: .medium))
                        .kerning(3.53)
                        .frame(height: 54)
                        .frame(maxWidth: .infinity)
                        .background(Color.brand2)
                        .clipShape(Capsule())
                        .padding()
                }
            }
            .background(Color.brand1.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct InsufficientCoinsView_Previews: PreviewProvider {
    static var previews: some View {
        InsufficientCoinsView()
    }
}

struct SGNavigationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let title: String
    var image: String? = nil
    var isBackHidden: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            if !isBackHidden {
                HStack {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(.leading, 8)
                            .tint(.text1)
                    }
                    Spacer()
                }
            }
            
            HStack {
                Text(title)
                    .font(.walsheimMedium(size: 18))
                    .foregroundColor(.text1)
                if image != nil {
                    Image(image!, bundle: nil)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
        .background(Color.brand1)
    }
}

struct TextBackgroundImageView: View {
    let text: String
    let image: String
    var imagePaddingleft: CGFloat = 56
    var imagePaddingRight: CGFloat = 56
    
    var body: some View {
        VStack {
            Text(text)
                .font(.walsheimRegular(size: 16))
                .foregroundColor(.text1.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 45)
            
            Spacer()
            
            Image(image, bundle: nil)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            //                .padding(.vertical, 50)
                .padding(.leading, imagePaddingleft)
                .padding(.trailing, imagePaddingRight)
            
            //            Spacer()
        }
    }
}
