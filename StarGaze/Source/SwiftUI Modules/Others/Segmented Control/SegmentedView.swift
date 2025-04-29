//
//  SegmentedView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 24/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct SegmentItemViewModel: Identifiable {
    let id = UUID().uuidString
    let title:String
    let iconName:String
}

struct SegmentedView: View, Equatable {
    @Binding private var currentSegment:Int
    @State private var frames: Array<CGRect>
    
    private var id:String = ""
    
    let segments:[SegmentItemViewModel]
    let showText: Bool
    
    init(id:String? = nil,
         selectedIndex: Binding<Int>,
         segments: [SegmentItemViewModel],
         showText: Bool = false) {
        self.id = id ?? ""
        self._currentSegment = selectedIndex.animation()
        self.segments = segments
        self.showText = showText
        
        frames = Array<CGRect>(repeating: .zero, count: segments.count)
    }
    
    var body: some View {
        HStack {
            ForEach(Array(segments.enumerated()),
                    id:\.1.id) {(index, segment) in
                
                SegmentItemView(iconName: segment.iconName,
                                title: segment.title,
                                isHighlighted: index == currentSegment,
                hideText: !showText)
                .onTapGesture {
                    withAnimation {
                        self.currentSegment = index
                    }
                }
                .frame(maxWidth: .infinity)
                .readFrame(space: .global,
                           onChange: { frame in
                    self.frames[index] = frame
                })                
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(height:62)
        .modifier(UnderlineModifier(selectedIndex: currentSegment,
                                    frames: frames))
    }
    
    static func == (lhs: SegmentedView, rhs: SegmentedView) -> Bool {
        return lhs.id == rhs.id //Preventing from rebuilding the body, on parent refresh
    }
}


//struct SegmentedView_Previews: PreviewProvider {
//    @State static var index: Int = 0
//    static var previews: some View {
//        SegmentedView(id: UUID().uuidString,
//            selectedIndex: $index.animation(),
//                      segments: SegmentItemViewModel.listPreview)
//            .preferredColorScheme(.light)
//    }
//}
