//
//  SGGradientView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

@IBDesignable
class SGGradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .black {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var midColor:UIColor = .black {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = .black {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var isVertical:Bool = true {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var midPosition:Float = 0.5 {
        didSet {
            self.updateGradient()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateGradient()
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateGradient() //Calling it from here, in case the view's size changes.
    }
    
    
    func updateGradient() {
        let layer = self.layer
        
        let gradientLayer  = layer as! CAGradientLayer
        gradientLayer.colors = [self.startColor.cgColor,
                                self.midColor.cgColor,
                                self.endColor.cgColor]
        gradientLayer.locations = [NSNumber(value: 0.0), NSNumber(value: midPosition), NSNumber(value: 1.0)]
        
        if isVertical {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        else {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
    }
}
