//
//  SGOverlayView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 03/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGOverlayView: UIView {

    required init(with info: SGOverlayInfo) {
        super.init(frame: .zero)
        setup(with: info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(with info: SGOverlayInfo) {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .center
        
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.spacing = 12
        textStackView.alignment = .center
                
        let icon = UIImage(systemName: info.icon) ?? UIImage(named: info.icon)
        if let image = icon?.withRenderingMode(.alwaysTemplate) {
            let iconView = UIImageView(image: image)
            iconView.tintColor = .white
            contentStackView.addArrangedSubview(iconView)
        }
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.numberOfLines = 1
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = info.title
        titleLabel.textColor = .white
        textStackView.addArrangedSubview(titleLabel)
        
        if let message = info.message, !message.isEmpty {
            let msgLabel = SGSpacedLabel()
            msgLabel.font = .systemFont(ofSize: 16, weight: .regular)
            msgLabel.textColor = .white
            msgLabel.numberOfLines = 2
            msgLabel.adjustsFontSizeToFitWidth = true
            msgLabel.minimumScaleFactor = 0.5
            msgLabel.lineHeight = 22.0
            msgLabel.text = message
            
            textStackView.addArrangedSubview(msgLabel)
        }
        
        contentStackView.addArrangedSubview(textStackView)
        

        let containerView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        containerView.pin(to: self)
                                
        contentStackView.centerAlign(to: self)
        contentStackView.pin(to: self, edges: .left, relation: .equal, inset: .init(top: 0, left: 28, bottom: 0, right: 0))
        contentStackView.pin(to: self, edges: .right, relation: .equal, inset: .init(top: 0, left: 0, bottom: 0, right: 28))
        
        self.backgroundColor = .clear
    }
}
