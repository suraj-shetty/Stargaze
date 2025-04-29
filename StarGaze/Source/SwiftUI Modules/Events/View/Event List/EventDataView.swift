//
//  EventStaticDataView.swift
//  StarGaze_Test
//
//  Created by Sourabh Kumar on 27/04/22.
//

import SwiftUI
import Kingfisher

struct EventDataView: View {
    let image: String
    let value: String
    
    var body: some View {
        VStack {
            Image(image, bundle: nil)
                .resizable()
                .frame(width: 20, height: 20)
                .aspectRatio(contentMode: .fit)
                .padding(8)
            Text(value)
                .font(.walsheimMedium(size: 14))
                .foregroundColor(.text1)
                .padding(.vertical, 5)
                .padding(.horizontal, 16)
                .background(Color.primary.opacity(0.1))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
    }
}

struct PreviousEventView: View {
    let image: String
    var body: some View {
        ZStack {
            KFImage(URL(string: image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .background(Color.slate)
                .clipShape(Circle())
                .shadow(color: Color.shadow, radius: 5, x: 0, y:5)
                .padding(.leading, -30)
            Image("arrowLeft", bundle: nil)
                .resizable()
                .frame(width: 41, height: 14)
                .padding(.leading, 30)
                .tint(Color.text1)
        }
    }
}

struct NextEventView: View {
    let image: String
    var body: some View {
        ZStack {
            KFImage(URL(string: image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .background(Color.slate)
                .clipShape(Circle())
                .shadow(color: Color.shadow, radius: 5, x: 0, y:5)
                .padding(.trailing, -30)
            Image("arrowRight", bundle: nil)
                .resizable()
                .frame(width: 41, height: 14)
                .padding(.trailing, 30)
                .tint(Color.text1)
        }
    }
}
