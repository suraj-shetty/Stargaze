//
//  SGLinkLabel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 04/08/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

import UIKit

//Source: https://github.com/stevencurtis/ClickableLabel/blob/master/ClickableLabel/InteractiveLinkLabel.swift
class SGLinkLabel: UILabel {

    var linkClickCallback: ((URL) -> ())? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    func configure() {
        isUserInteractionEnabled = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let locationOfTouchInLabel = touches.first?.location(in: self)
        else {
            super.touchesCancelled(touches, with: event)
            return
        }
        
        handleTouch(at: locationOfTouchInLabel) {
            super.touchesCancelled(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // get the tapped character location
        guard let locationOfTouchInLabel = touches.first?.location(in: self)
        else {
            super.touchesEnded(touches, with: event)
            return
        }
        
        handleTouch(at: locationOfTouchInLabel) {
            super.touchesEnded(touches, with: event)
        }
    }
    
    private func handleTouch(at location:CGPoint, completion:()->()) {
        // Configure NSTextContainer
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        // Configure NSLayoutManager and add the text container
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        guard let attributedText = attributedText else {
            completion()
            return
        }
        
        // Configure NSTextStorage and apply the layout manager
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSMakeRange(0, attributedText.length))
        textStorage.addLayoutManager(layoutManager)
        
        // account for text alignment and insets
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        var alignmentOffset: CGFloat!
        switch textAlignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        @unknown default:
            fatalError()
        }
        
        let xOffset = ((bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
        let yOffset = ((bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
        let locationOfTouchInTextContainer = CGPoint(x: location.x - xOffset, y: location.y - yOffset)
        
        // work out which character was tapped
        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let attributeName = NSAttributedString.Key.attachment
        let attributeValue = self.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
        
        if let value = attributeValue {
            if let url = value as? URL {
                linkClickCallback?(url)
            }
        }
        completion()
    }
}
