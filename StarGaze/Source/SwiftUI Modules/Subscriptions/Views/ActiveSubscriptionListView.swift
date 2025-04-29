//
//  ActiveSubscriptionListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 05/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct ActiveSubscriptionListView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            navView()
            
        }
    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image("navBack")
                        .frame(width: 49,
                               height: 44)
                }
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text("active-subscription.nav.title")
                    .font(.system(size: 18,
                                  weight: .medium))
                    .foregroundColor(.text1)
                
                Spacer()
            }
        }
        .frame(height: 44)
        .background {
            Color.brand1
                .ignoresSafeArea(.all,
                                 edges: .top)
        }
    }
    
    
}

struct ActiveSubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveSubscriptionListView()
    }
}
