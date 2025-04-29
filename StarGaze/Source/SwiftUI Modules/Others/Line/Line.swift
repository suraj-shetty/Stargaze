//
//  Line.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 19/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

enum LineDirection {
    case horizontal
    case vertical
}

struct Line: Shape {
    var direction: LineDirection = .horizontal
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (direction == .horizontal) ? rect.width : 0,
                                 y: (direction == .vertical) ? rect.height : 0))
        return path
    }
}

