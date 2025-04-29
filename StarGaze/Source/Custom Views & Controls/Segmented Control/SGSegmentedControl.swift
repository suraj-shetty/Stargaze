//
//  SGSegmentedControl.swift
//  StarGaze
//
//  Created by Suraj Shetty on 16/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine

struct SGSegmentStyle {
    var font:UIFont!
    var baseColor:UIColor!
    var highlightColor:UIColor!
    var borderWidth:CGFloat
    var cornerRadius:CGFloat
    var letterSpacing:CGFloat
    
    static var `default`: SGSegmentStyle {
        return .init(font: UIFont.systemFont(ofSize: 13, weight: .medium),
                     baseColor: .segmentTextHighlight,
                     highlightColor: .brand2,
                     borderWidth: 1,
                     cornerRadius: 15,
                     letterSpacing: -0.08)
    }
}

struct SGSegmentItemViewModel: Equatable {
    let title:String
    
    static func ==(lhs: SGSegmentItemViewModel, rhs: SGSegmentItemViewModel) -> Bool {
        return lhs.title == rhs.title
    }
}

@IBDesignable
class SGSegmentedControl: UIControl {

    private let contentView = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    
    var style:SGSegmentStyle = .default {
        didSet { updateAppearance() }
    }
    
    var segments: [SGSegmentItemViewModel]  = [] {
        didSet {
            setupSegments()
            current = segments.first
        }
    }
    
    var current:SGSegmentItemViewModel? = nil {
        willSet {
            if let value = newValue {
                highlight(value)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
        segments = [SGSegmentItemViewModel(title: "Generic Feeds"), SGSegmentItemViewModel(title: "Exclusive")]
    }
    
    private func setupView() {
        contentView.distribution = .fillEqually
        contentView.axis = .horizontal
        contentView.pin(to: self)
        contentView.clipsToBounds = true
//        setupSegments()
    }

    private func setupSegments() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        contentView.arrangedSubviews.forEach({ $0.removeFromSuperview()})
        
        segments.forEach { segment in
            let segmentLabel = SGSpacedLabel()
            segmentLabel.text = segment.title
            segmentLabel.textAlignment = .center
            segmentLabel.isUserInteractionEnabled = true
            segmentLabel.gesture(.tap())
                .sink {[weak self] _ in
                    if self?.current != segment {
                        self?.current = segment
                        self?.sendActions(for: .valueChanged)
                    }
                }
                .store(in: &cancellables)
            
            contentView.addArrangedSubview(segmentLabel)
        }
        
        if segments.isEmpty == false {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        let segmentLabels = contentView.arrangedSubviews.map({ $0 as! SGSpacedLabel})
        segmentLabels.forEach { segmentLabel in
            segmentLabel.font = style.font
            segmentLabel.textColor = style.highlightColor
            segmentLabel.highlightedTextColor = style.baseColor
            segmentLabel.letterSpacing = style.letterSpacing
        }
        
        contentView.layer.cornerRadius = style.cornerRadius
        contentView.layer.borderColor = style.highlightColor.cgColor
        contentView.layer.borderWidth = style.borderWidth
    }
    
    private func highlight(_ segment:SGSegmentItemViewModel) {
        if current == segment { return }
        
        if let current = current, let currentIndex = segments.firstIndex(of: current) {
            let label = contentView.arrangedSubviews[currentIndex] as? SGSpacedLabel
            
            label?.isHighlighted = false
            label?.backgroundColor = .clear
            label?.shadowColor = .clear
            label?.shadowOffset = .zero
        }
        
        if let index = segments.firstIndex(of: segment) {
            let label = contentView.arrangedSubviews[index] as? SGSpacedLabel
            label?.isHighlighted = true
            label?.backgroundColor = style.highlightColor
            label?.shadowColor = .black.withAlphaComponent(0.5)
            label?.shadowOffset = .zero
        }
    }
}
