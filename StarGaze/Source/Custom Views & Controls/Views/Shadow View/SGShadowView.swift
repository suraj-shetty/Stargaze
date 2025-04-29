//
//  SGShadowView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

@IBDesignable
class SGShadowView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            updateShadowPath()
            updateShadow()
        }
    }
    
    var corners:UIRectCorner = [.allCorners] {
        didSet { updateShadowPath() }
    }
    
    @IBInspectable var shadowColor:UIColor? = UIColor.black {
        didSet { updateShadow() }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 5.0) {
        didSet { updateShadow() }
    }
    
    @IBInspectable var shadowRadius:CGFloat = 10.0 {
        didSet { updateShadow() }
    }
    
    @IBInspectable var shadowOpacity:Float = 0.3 {
        didSet { updateShadow() }
    }
    
    override var backgroundColor: UIColor? {
        didSet { updateShadow() }
    }

    
    override class var layerClass: AnyClass {
        get { return CAShapeLayer.self }
    }
    
    private var shadowLayer:CAShapeLayer? {
        get { return layer as? CAShapeLayer }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateShadow()
        updateShadowPath()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateShadow()
        updateShadowPath()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow()
        updateShadowPath()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateShadow()
        updateShadowPath()
    }
    
    private func updateShadow() {
        
        shadowLayer?.fillColor = backgroundColor?.cgColor
        shadowLayer?.shadowColor = shadowColor?.cgColor
        shadowLayer?.shadowOffset = shadowOffset
        shadowLayer?.shadowOpacity = shadowOpacity
        shadowLayer?.shadowRadius = shadowRadius
        shadowLayer?.rasterizationScale = UIScreen.main.scale
    }
    
    private func updateShadowPath() {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        
        shadowLayer?.path = path
        shadowLayer?.shadowPath = path
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
