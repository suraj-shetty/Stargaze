//
//  AspectRatioPicker.swift
//  StarGaze
//
//  Created by Suraj Shetty on 04/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct AspectRatioPicker: View {
    var options: [SGMediaAspectRatio]
    @Binding var picked: SGMediaAspectRatio
        
    var completion: (Bool) -> ()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            
            VStack(spacing: 0) {
                Spacer()
                
                AspectRatioToolbar(options: options,
                                   current: $picked) { didChange in
                    self.completion(didChange)
                }
            }
        }
    }
}

struct AspectRatioPicker_Previews: PreviewProvider {
    static var previews: some View {
        AspectRatioPicker(options: [.square, .aspect16x9], picked: .constant(SGMediaAspectRatio.square)) { _ in
            
        }
    }
}
