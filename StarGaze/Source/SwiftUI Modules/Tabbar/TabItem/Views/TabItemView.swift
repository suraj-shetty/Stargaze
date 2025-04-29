//
//  TabItemView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct TabItemView: View {
    let item: TabItemData
    let isSelected: Bool
    
    var body: some View {
        HStack(alignment: .center,
               spacing: 9) {
            Image(item.image)
                .renderingMode(.template)
                .tint(isSelected ? .brand2 : .tabItemColor)
            
            if isSelected {
                Text(item.title)
                    .foregroundColor(.brand2)
                    .font(.system(size: 14, weight: .medium))
            }
        }
               .animation(.easeInOut, value: isSelected)
    }
}

//struct TabItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabItemView()
//    }
//}
