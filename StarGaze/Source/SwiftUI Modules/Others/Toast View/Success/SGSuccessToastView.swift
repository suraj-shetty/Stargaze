//
//  SGSuccessToastView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct SGSuccessToastView: View {
    @State var message:String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.white)
                    .font(.system(size: 36, weight: .semibold))
                
                Text(message)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color((UIColor(rgb: 0x44bd32))))
            .cornerRadius(8)
            .shadow(radius: 4)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct SGSuccessToastView_Previews: PreviewProvider {
    static var previews: some View {
        SGSuccessToastView(message: "Your feed was successfully created.")
    }
}
