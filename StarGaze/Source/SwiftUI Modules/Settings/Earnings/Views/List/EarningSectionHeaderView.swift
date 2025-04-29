//
//  EarningSectionHeaderView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 16/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarningSectionHeaderView: View {
    var title: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
        
            Text(title)
                .font(.system(size: 14,
                              weight: .medium))
                .foregroundColor(.text2)
                .opacity(0.5)
            
            Spacer()
        }
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Color.earningViewBackground)
        }
    }
}

struct EarningSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        EarningSectionHeaderView(title: "Wed 25 Nov 2022")
    }
}
