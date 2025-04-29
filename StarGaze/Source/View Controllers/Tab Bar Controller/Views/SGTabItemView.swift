//
//  SGTabBarController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 16/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGTabItemView: UIView {
    @IBOutlet weak public var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    static var instance: SGTabItemView{
        return Bundle.main.loadNibNamed(TAB_ITEM_VIEW_XIB, owner: nil, options: nil)?.first as! SGTabItemView
    }        
    
    var isSelected: Bool = false{
        willSet{
            updateUI(isSelected: newValue)
        }
    }
    
    var item: Any? {
        didSet{
            configure(item)
        }
    }
    
    private func configure(_ item: Any?){
        guard let model = item as? SGTabBarItem else { return }
        titleLabel.text = model.title
        imageView.image = UIImage(named: model.image)
        imageView.highlightedImage = UIImage(named: model.imageSelected)
        
        isSelected = model.isSelected
    }
    
    
    private func updateUI(isSelected: Bool){
        guard let model = item as? SGTabBarItem else { return }
        model.isSelected = isSelected
        let options: UIView.AnimationOptions = isSelected ? [.curveEaseIn] : [.curveEaseOut]
        
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: options,
                       animations: {
            self.titleLabel.text = isSelected ? model.title : ""
            self.imageView.isHighlighted = isSelected
            self.superview?.layoutIfNeeded()
        },
                       completion: nil)
    }
}
