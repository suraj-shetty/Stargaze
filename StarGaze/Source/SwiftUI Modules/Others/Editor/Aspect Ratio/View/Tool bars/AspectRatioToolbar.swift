//
//  AspectRatioToolbar.swift
//  PhotoLibrary
//
//  Created by Suraj Shetty on 06/07/22.
//

import SwiftUI

struct AspectRatioToolbar: View {
    
    var options: [SGMediaAspectRatio]
    @Binding var current: SGMediaAspectRatio
    var completion: (Bool) -> ()
    
    var body: some View {
        VStack {
//            Spacer()
            Color.clear
                .frame(height: 0)
            
            GeometryReader { proxy in
                let spacing: CGFloat = self.spacing(for: proxy.size.width)
                
                HStack(alignment: .center,
                       spacing: spacing) {
                                            
                    ForEach (options, id: \.self) { option in
                        cellView(for: option)
                    }
                    
                    Color.clear
                }
                
//                ScrollView(.horizontal,
//                           showsIndicators: false) {
//
//                }
            }
            .frame(height: 80)
            
            HStack(alignment: .center) {
                Button {
                    completion(false)
                } label: {
                    Image(systemName: "xmark")
//                        .frame(width: 40, height: 40)
                }
                .frame(minWidth: 44,
                       maxWidth: 44,
                       maxHeight: .infinity)
                
                Spacer()
                
                Button {
                    completion(true)
                } label: {
                    Image(systemName: "checkmark")
//                        .frame(width: 40, height: 40)
                }
                .frame(minWidth: 44,
                       maxWidth: 44,
                       maxHeight: .infinity)
            }
            .background(Color.toolBackground)
            .frame(height: 44)
            
//            Spacer()
        }
        .tint(.white)
//        .frame(height:92)
        .background(Color.controlBackground)
    }
    
    private func cellView(for option: SGMediaAspectRatio) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            
            Rectangle()
                .stroke(Color.iconBorder,
                        lineWidth: 1)
                .background(Color.iconBackground)
                .frame(width: 40,
                       height: 40/option.ratio)
            
            Spacer()
            Text(option.title)
                .foregroundColor((option == current) ? .white : .iconBorder)
                .font(.system(size: 12,
                              weight: .semibold))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
            
            Color.clear
                .frame(height: 6)
        }
        .frame(width: 80,
               height: 80)
        .border(Color.yellow,
                width: (option == current) ? 2 : 0)
        .onTapGesture {
            if current != option {
                withAnimation {
                    self.current = option
                }
            }
        }
    }
    
    private func spacing(for width: CGFloat) -> CGFloat {
        var spacing: CGFloat = 10
        let count = options.count
        
        if count > 1 {
        spacing = (width - CGFloat(72 * count)) / CGFloat(count + 1)
        }
        
        return spacing
    }
}

struct AspectRatioToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            AspectRatioToolbar(options: [.square, .aspect16x9, .aspect4x3, .aspect3x2],
                               current: .constant(.aspect3x2),
                               completion: { _ in
                
            })
            Spacer()
        }
    }
}

extension SGMediaAspectRatio {
    var title: String {
        switch self {
        case .square:
            return "Square"
        case .aspect4x3:
            return "4:3"
        case .aspect16x9:
            return "16:9"
        case .aspect3x2:
            return "3x2"            
        case .aspect2x3:
            return "2x3"
        case .aspect4x5:
            return "4x5"
        case .aspect(let width, let height):
            return "\(width):\(height)"
        case .ratio(let double):
            return "\(double):1"
        }
    }
}
