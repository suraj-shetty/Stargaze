//
//  SGRoundedView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

@IBDesignable
class SGRoundedView: UIView {
    
    @IBInspectable var cornerRadius:CGFloat = 5.0 {
        didSet {
            configureView()
        }
    }
    
    var corners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner,
                                 .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    {
        didSet {
            configureView()
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        didSet {
            configureView()
        }
    }
    
    
    @IBInspectable var borderColor:UIColor = UIColor.white {
        didSet {
            configureView()
        }
    }
    
    @IBInspectable var shouldAddShadow:Bool = false {
        didSet {
            if (shouldAddShadow == true) { configureShadow() }
            else { removeShadow() }
        }
    }
    
    weak var shadowLayer:CAShapeLayer?
    @IBInspectable var shadowColor:UIColor? = UIColor.black {
        didSet {
            configureShadow()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 5.0) {
        didSet {
            configureShadow()
        }
    }
    
    @IBInspectable var shadowRadius:CGFloat = 10.0 {
        didSet {
            configureShadow()
        }
    }
    
    @IBInspectable var shadowOpacity:Float = 0.3 {
        didSet {
            configureShadow()
        }
    }
    
//    @IBInspectable var cornerRadius:CGFloat = 6 {
//        didSet {
//            shadowLayer?.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
//            shadowLayer?.shadowPath = shadowLayer?.path
//        }
//    }
    
    override var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = backgroundColor
            shadowLayer?.fillColor = backgroundColor?.cgColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureView()
    }
    
    
    private func configureView() {
        layer.cornerRadius  = cornerRadius
        layer.maskedCorners =  corners
        layer.borderWidth   = borderWidth
        layer.borderColor   = borderColor.cgColor
        
        clipsToBounds = true
        
        if shouldAddShadow == true {
            configureShadow()
        }
    }
    
    private func configureShadow() {
        if shadowLayer == nil {
            let shadowLayer = CAShapeLayer()
            layer.insertSublayer(shadowLayer, at: 0)
            self.shadowLayer = shadowLayer
        }
        
        let shadowCorners = rectCorners()
        shadowLayer?.path = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: shadowCorners,
                                              cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        shadowLayer?.fillColor = backgroundColor?.cgColor
        shadowLayer?.shadowColor = shadowColor?.cgColor
        shadowLayer?.shadowPath = shadowLayer?.path
        shadowLayer?.shadowOffset = shadowOffset
        shadowLayer?.shadowOpacity = shadowOpacity
        shadowLayer?.shadowRadius = shadowRadius
        shadowLayer?.rasterizationScale = UIScreen.main.scale
    }
    
    private func removeShadow() {
        shadowLayer?.removeFromSuperlayer()
        shadowLayer = nil
    }
    
    private func rectCorners() -> UIRectCorner {
        var rectCorners = UIRectCorner()
        if(corners.contains(.layerMinXMinYCorner)){
            rectCorners.insert(.topLeft)
        }
        if(corners.contains(.layerMaxXMinYCorner)){
            rectCorners.insert(.topRight)
        }
        if(corners.contains(.layerMinXMaxYCorner)){
            rectCorners.insert(.bottomLeft)
        }
        if(corners.contains(.layerMaxXMaxYCorner)){
            rectCorners.insert(.bottomRight)
        }
        return rectCorners
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
