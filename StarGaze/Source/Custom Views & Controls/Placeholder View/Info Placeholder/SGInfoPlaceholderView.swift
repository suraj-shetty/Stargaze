//
//  SGInfoPlaceholderView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 17/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit


class SGInfoPlaceholderView: UIView {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: SGSpacedLabel!
           
    
    func configure(with viewModel:SGPlaceholderViewModel) {
        iconView.image = UIImage(named: viewModel.iconName)
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.desc
    }
}
