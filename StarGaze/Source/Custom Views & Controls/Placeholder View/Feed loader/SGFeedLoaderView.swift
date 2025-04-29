//
//  SGFeedLoaderView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import SkeletonView

class SGFeedLoaderView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            let gradient = SkeletonGradient(baseColor:.text1.withAlphaComponent(0.1),
                                            secondaryColor: .text1.withAlphaComponent(0.2))
            let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
            self.showAnimatedGradientSkeleton(usingGradient: gradient,
                                              animation: animation,
                                              transition: .crossDissolve(0.25))
        }
        else {
            self.hideSkeleton()
        }
    }
    
}
