//
//  SGAppIntroCollectionViewCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGAppIntroCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: SGSpacedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
