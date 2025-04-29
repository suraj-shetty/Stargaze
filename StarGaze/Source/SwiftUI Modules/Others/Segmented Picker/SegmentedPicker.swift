//
//  SegmentedPicker.swift
//  StarGaze
//
//  Created by Suraj Shetty on 30/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Combine

struct SegmentedPicker: UIViewRepresentable {
    typealias UIViewType = SGSegmentedControl
    
    @Binding var index:Int
    var segments:[SGSegmentItemViewModel]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    func makeUIView(context: Context) -> SGSegmentedControl {
        let control = SGSegmentedControl()
        control.segments = segments
        control.addTarget(context.coordinator,
                          action: #selector(Coordinator.onSegmentChange(_:)),
                          for: .valueChanged)
                
        return control
    }
    
    func updateUIView(_ uiView: SGSegmentedControl, context: Context) {
        uiView.current = segments[index]
    }
    
    static func dismantleUIView(_ uiView: SGSegmentedControl, coordinator: Coordinator) {
        uiView.removeTarget(coordinator,
                            action: #selector(Coordinator.onSegmentChange(_:)),
                            for: .valueChanged)
    }
}

extension SegmentedPicker {
    class Coordinator: NSObject {
        var parent:SegmentedPicker
        
        init(_ picker:SegmentedPicker) {
            parent = picker
        }
                
        @objc func onSegmentChange(_ control:SGSegmentedControl) {
            guard let pickedSegment = control.current,
                    let index = parent.segments.firstIndex(of: pickedSegment)
            else { return }
            
            
            
            parent.index = index
        }
    }
}


struct SegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedPicker(index: .constant(0),
                        segments: [SGSegmentItemViewModel(title: "Generic"),
                                   SGSegmentItemViewModel(title: "Exclusive")])
    }
}
