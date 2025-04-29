//
//  EarnCoinsView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 16/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarnCoinsView: View {
    let types: [EarnCoinTypes] = EarnCoinTypes.allCases
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 11) {
            SGNavigationView(title: NSLocalizedString("earn.coins.nav.title",
                                                      comment: ""))
            .frame(height: 34)
            .padding(.horizontal, 12)
            
            List {
                ForEach (Array(types.enumerated()), id: \.1.self) { index, type in
                    cell(of: type,
                         index: index,
                         isLastRow: (index < types.count-1)
                         ? false
                         : true
                    )
                }
            }
            .listStyle(.plain)
        }
        
        .background(Color.brand1.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func cell(of type: EarnCoinTypes, index:Int, isLastRow: Bool) -> some View {
        
        VStack(spacing: 19) {
            HStack(alignment: .center, spacing: 15) {
                Text(String(format: "%02d", index+1))
                    .foregroundColor(.brand2)
                    .font(.system(size: 28, weight: .regular))
                    
                
                Text(type.descKey)
                    .foregroundColor(.text1)
                    .font(.system(size: 15, weight: .regular))
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .foregroundColor(.tableSeparator)
                .frame(maxWidth: .infinity, maxHeight: 1)
                .opacity(isLastRow ? 0 : 1)
        }
        .listRowInsets(EdgeInsets(top: 20, leading: 19, bottom: 0, trailing: 19))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
    }
    
    @ViewBuilder
    private func cellBackground() -> some View {
        if colorScheme == .dark {
            Color.earnCoinsCellBackground
        }
        else {
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                Color.earnCoinsCellBackground
                    .opacity(0.8)
            }
        }
    }
}

struct EarnCoinsView_Previews: PreviewProvider {
    static var previews: some View {
        EarnCoinsView()
    }
}
