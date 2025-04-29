//
//  EarningListCellView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 16/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarningListCellView: View {
    var iconName: String
    var titleText: String
    var amountText: String
    
    var body: some View {
        HStack(alignment: .top,
               spacing: 13) {
            Image(iconName)
                .renderingMode(.template)
                .foregroundColor(.earningIconTint)
            
            Text(titleText)
                .foregroundColor(.text1)
                .font(.system(size: 16,
                              weight: .regular))
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 39)
            
            Text(amountText)
                .foregroundColor(.brand2)
                .font(.system(size: 16,
                              weight: .regular))
                .lineSpacing(2)
        }
    }
}

struct EarningListCellView_Previews: PreviewProvider {
    static var previews: some View {
        EarningListCellView(iconName: "earningShows",
                            titleText: "Diwali night show form dehli Diwali",
                            amountText: "Rs. 570")
    }
}
