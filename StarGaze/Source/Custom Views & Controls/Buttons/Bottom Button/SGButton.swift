//
//  SGBottomButton.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

@IBDesignable
class SGButton: UIButton {
    
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    @IBInspectable var bgColor:UIColor? = UIColor.white {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    @IBInspectable var letterSpacing:CGFloat = 0.0 {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
//    @IBInspectable var disabledBgColor:UIColor? = UIColor.white {
//        didSet {
//            updateContent()
//        }
//    }
    
    override func updateConfiguration() {
        var configuration = self.configuration ?? .filled()
        configuration.baseBackgroundColor = bgColor
        configuration.background.cornerRadius = cornerRadius
        configuration.cornerStyle = .fixed
        
        if var attributedTitle = configuration.attributedTitle {
            attributedTitle.kern = letterSpacing
            configuration.attributedTitle = attributedTitle
        }
        else if let title = configuration.title {
            var attributedTitle = AttributedString(title)
            attributedTitle.kern = letterSpacing
            configuration.attributedTitle = attributedTitle
        }
        
        
        if let safeAreaInset = (UIApplication.shared.delegate?.window??.safeAreaInsets) {
            let bottomInset = safeAreaInset.bottom
            if bottomInset > 0 {
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
            }
            else {
                configuration.contentInsets = .zero
            }
        }
        
        self.configuration = configuration
    }
}
