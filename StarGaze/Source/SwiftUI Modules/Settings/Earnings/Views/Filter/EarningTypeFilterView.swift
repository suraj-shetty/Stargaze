//
//  EarningTypeFilterView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI
import WrappingHStack

struct EarningTypeFilterView: View {
    private var types:[EarningType] = [.show, .event, .feed, .subscription]
    
    @State var picked:[EarningType] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Filter Earnings")
                    .foregroundColor(.text1)
                    .font(.system(size: 18, weight: .medium))
                
                HStack {
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Reset")
                            .foregroundColor(.brand2)
                            .font(.system(size: 18, weight: .medium))
                            .underline(true, color: .brand2)
                    }
                    .frame(height: 44)
                }
            }
            .padding(.bottom, 15)
                   
            WrappingHStack(types,
                           spacing: .constant(16),
                           lineSpacing: 14) { type in
                
                let contains = picked.contains(type)
                
                HStack(alignment: .center, spacing: 6) {
                    Image(type.icon)
                        .renderingMode(.template)
                        .foregroundColor(contains ? .brand2 : .text2.opacity(0.5))
                    
                    Text(type.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(contains ? .brand2 : .text2.opacity(0.5))
                }
                .padding(.horizontal, 21)
                .padding(.vertical, 13)
                .background {
                    Capsule()
                        .strokeBorder(contains ? Color.clear : Color.text2.opacity(0.5),
                                      lineWidth: 1.0)
                        .background {
                            Color.brand2
                                .opacity(contains ? 0.19 : 0.0)
                                .clipShape(Capsule())
                        }
                }
                .onTapGesture {
                    if contains {
                        picked.removeAll(where: { $0 == type })
                    }
                    else {
                        picked.append(type)
                    }
                }
              }
            
            SGRoundRectButton(title: "APPLY") {
                
            }
            .disabled(picked.isEmpty)
            .opacity(picked.isEmpty ? 0.5 : 1.0)
            .padding(.horizontal, -20)
            .padding(.top, 14)
        }
        .padding(.horizontal, 20)
        .background {
            Color.brand1
        }
    }
}

struct EarningTypeFilterView_Previews: PreviewProvider {
    static var previews: some View {
        EarningTypeFilterView()
    }
}
