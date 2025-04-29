//
//  SegmentItemView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 24/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI


struct SegmentItemView: View {
    var iconName:String = ""
    var title:String = ""
    var isHighlighted:Bool = false
    var hideText: Bool = true
    
    var body: some View {
        HStack(alignment: .center, spacing: 10, content: {
            Image(iconName)
                .renderingMode(.template)
                .frame(height:22)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(isHighlighted ? .brand2 : .text1)
            
            if !hideText || isHighlighted {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isHighlighted ? .brand2 : .text1)
            }
        })
    }
}

struct SegmentItemView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentItemView(iconName: "feedsSegment", title: "Feeds", isHighlighted: true)
    }
}
