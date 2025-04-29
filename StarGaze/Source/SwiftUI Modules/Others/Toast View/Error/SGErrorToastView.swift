//
//  SGErrorToastView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct SGErrorToastView: View {
    @State var message:String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "xmark.octagon.fill")
                    .foregroundColor(Color.white)
                    .font(.system(size: 36, weight: .semibold))
                
                Text(message)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
            }
            .padding()
            .background(Color((UIColor(rgb: 0xef5557))))
            .cornerRadius(8)
            .shadow(radius: 4)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct SGErrorToastView_Previews: PreviewProvider {
    static var previews: some View {
        SGErrorToastView(message: "An error occured. Please try again.")
    }
}
