//
//  SGIntroPageControl.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

@IBDesignable
class SGIntroPageControl: UIControl {

    fileprivate var pageIndicators = [CAShapeLayer]()
    fileprivate let currentPageIndicator  = CAShapeLayer()
    
    @IBInspectable var numberOfPages: Int = 0 {
        didSet {
            updatePageCount(numberOfPages)
        }
    }
    
    @IBInspectable var progress:Double = 0 {
        didSet {
            update(for: progress)
        }
    }
    
    var currentPage: Int {
        return Int(progress)
    }
    
    @IBInspectable var padding:CGFloat = 5 {
        didSet {
            setNeedsLayout()
            update(for: progress)
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            setNeedsLayout()
        }
    }
        
    
    @IBInspectable var currentPageTintColor:UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var currentPageBorderWidth:CGFloat = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var pageIndicatorSize:CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var currentPageIndicatorSize:CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsLayout()
    }
    
    
    //MARK: -
    func updatePageCount(_ count:Int) {
        pageIndicators.forEach({ $0.removeFromSuperlayer() })
        pageIndicators  = (0..<count).map { _ in
            let pageLayer = CAShapeLayer()
            self.layer.addSublayer(pageLayer)
            
            return pageLayer
        }
        
        self.layer.addSublayer(currentPageIndicator)
        setNeedsLayout()
        self.invalidateIntrinsicContentSize()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let xEdge = (currentPageIndicatorSize.width > pageIndicatorSize.width) ? (currentPageIndicatorSize.width - pageIndicatorSize.width)/2.0 : 0.0
        let yEdge = (currentPageIndicatorSize.height > pageIndicatorSize.height) ? (currentPageIndicatorSize.height - pageIndicatorSize.height)/2.0 : 0.0
        
        var frame = CGRect(x: 0, y: yEdge, width: pageIndicatorSize.width, height: pageIndicatorSize.height)
        
        pageIndicators.enumerated().forEach { (index, layer) in
            layer.fillColor = tintColor.cgColor
            layer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: pageIndicatorSize)).cgPath
            layer.frame = frame
            
            frame.origin.x += pageIndicatorSize.width + padding
        }
        
        currentPageIndicator.frame = CGRect(origin: .init(x: -xEdge, y: 0), size: currentPageIndicatorSize)
        currentPageIndicator.backgroundColor = currentPageTintColor?.cgColor
        currentPageIndicator.borderColor = tintColor.cgColor
        currentPageIndicator.borderWidth = currentPageBorderWidth
        currentPageIndicator.cornerRadius  = min(currentPageIndicatorSize.width, currentPageIndicatorSize.height)/2.0
//        currentPageIndicator.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: currentPageIndicatorSize)).cgPath
        update(for: progress)
    }
    
    func update(for progress:Double) {
        guard let min = pageIndicators.first?.frame,
                      let max = pageIndicators.last?.frame,
                      numberOfPages > 1,
                      progress >= 0 && progress <= Double(numberOfPages - 1)
        else { return }
        
        let total = Double(numberOfPages - 1)
        let dist = max.origin.x - min.origin.x
        let percent = CGFloat(progress / total)
        let offset = dist * percent
        
        var indicatorFrame = CGRect(origin: .zero, size: pageIndicatorSize)
        indicatorFrame.origin.x = min.origin.x + offset
        
        currentPageIndicator.position = CGPoint(x: indicatorFrame.midX, y: bounds.midY)
    }
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let maxHeight = max(pageIndicatorSize.height, currentPageIndicatorSize.height)
        let width =  (CGFloat(numberOfPages) * pageIndicatorSize.width) + (CGFloat(numberOfPages - 1) * self.padding)
        
        return CGSize(width: width,
                      height: maxHeight)
    }
}
