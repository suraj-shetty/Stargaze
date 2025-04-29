//
//  NewPostToastView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 25/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct NewPostToastView: View {
    var body: some View {
  
        HStack(alignment: .center, spacing: 8) {
            Text("feed.list.new-post.title".localizedKey)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Image("arrowUp")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.textFieldTitle)
        )
    }
}

struct NewPostToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                NewPostToastView()
                
                Spacer()
            }
            
            Spacer()
        }
    }
}
