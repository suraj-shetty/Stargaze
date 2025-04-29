//
//  SGSpacedLabel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

@IBDesignable
class SGSpacedLabel: UILabel {

    @IBInspectable var letterSpacing:CGFloat = 0.0 {
        didSet {
            updateText()
        }
    }
    
    @IBInspectable var lineHeight:CGFloat = 0 {
        didSet {
            updateText()
        }
    }
    
    @IBInspectable var changeLineHeight:Bool = false {
        didSet {
            updateText()
        }
    }
    
    
    override var text: String? {
        didSet {
            updateText()
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            updateText()
        }
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateText()
    }

    private func updateText() {
        let currentText = text ?? ""
        let attribText = attributedText ?? NSAttributedString(string: currentText)
        
        let count = attributedText?.string.utf16.count ?? 0
        
        guard count > 0 else {
            super.text = ""
            return
        }
        
        let updatedAttributedText = NSMutableAttributedString(attributedString: attribText)
        updatedAttributedText.addAttribute(.kern,
                                           value: letterSpacing,
                                           range: NSMakeRange(0, count))
        
        if changeLineHeight == true {
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.alignment = textAlignment
            paraStyle.minimumLineHeight = lineHeight
            updatedAttributedText.addAttribute(.paragraphStyle,
                                               value: paraStyle,
                                               range: NSMakeRange(0, count))

        }
        super.attributedText = updatedAttributedText
    }
}
