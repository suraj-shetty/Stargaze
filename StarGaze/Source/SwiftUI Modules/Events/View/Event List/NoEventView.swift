//
//  NoEventView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct NoEventView: View {
    var body: some View {
        VStack {
            Image("no_events", bundle: nil)
                .resizable()
                .padding(.horizontal, 52)
                .aspectRatio(contentMode: .fit)
            
            Text("Ongoing Events")
                .foregroundColor(.text1)
                .font(.louisianaRegular(size: 38))
                .padding(.bottom, -30)
                .padding(.top)
            Text("No Events..".uppercased())
                .multilineTextAlignment(.center)
                .font(.brandonBlk(size: 46))
                .foregroundColor(.text1)
//            Text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit.")
//                .fixedSize(horizontal: false, vertical: true)
//                .font(.walsheimRegular(size: 18))
//                .multilineTextAlignment(.center)
//                .foregroundColor(.text1)
//                .padding(.horizontal, 36)
//                .lineLimit(3)
        }
        .background(Color.brand1)
    }
}

struct NoEventView_Previews: PreviewProvider {
    static var previews: some View {
        NoEventView()
    }
}
