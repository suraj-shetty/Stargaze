//
//  EarningPickedRangeView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarningPickedRangeView: View {
    var pickedRange: EarningDateRangeType
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "calendar")
                .foregroundColor(.earningIconTint)
            
            Text(pickedRange.title)
                .foregroundColor(.earningIconTint)
                .font(.system(size: 12, weight: .regular))
            
            Triangle()
                .fill(Color.earningIconTint)
                .frame(width: 7, height: 7)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background {
            Capsule()
                .stroke(Color.earningIconTint,
                        lineWidth: 0.5)
        }
        
    }
}

struct EarningPickedRangeView_Previews: PreviewProvider {
    static var previews: some View {
        EarningPickedRangeView(pickedRange: .month)
    }
}
