//
//  TabBottomView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct TabBottomView: View {
    let tabbarItems: [TabItemData]
    @Binding var selectedIndex: Int
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                
                ForEach(tabbarItems.indices, id: \.self) { index in
                    let item = tabbarItems[index]
                    
                    Button {
                        self.selectedIndex = index
                    } label: {
                        let isSelected = selectedIndex == index

                        VStack(spacing: 0) {
                            Spacer()
                            
                            TabItemView(item: item, isSelected: isSelected)
                                .padding()
                            
                            Spacer()
                        }
                    }
                    .frame(height: proxy.size.height)
                    
                    Spacer()
                }
            }
            .background(
                Color.clear
            )
        }
    }
}

struct TabBottomView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            Spacer()
            
            TabBottomView(tabbarItems: TabType.allCases.map{ $0.tabItem },
                          selectedIndex: .constant(0))
            .frame(height: 60)
        }
        .preferredColorScheme(.dark)
    }
}
