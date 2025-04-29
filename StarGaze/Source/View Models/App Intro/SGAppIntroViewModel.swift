//
//  SGAppIntroViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Foundation

class SGAppIntroViewModel: NSObject {

    var title:String!
    var subTitle:String!
    var imageName:String!
    
    convenience init(title:String, subTitle:String, imageImage:String) {
        self.init()
        self.title = title
        self.subTitle = subTitle
        self.imageName = imageImage
    }
    
    func setup(_ cell: UICollectionViewCell) {
        guard let cell = cell as? SGAppIntroCollectionViewCell
        else { return }
        
        cell.titleLabel.text = title
        cell.subTitleLabel.text = subTitle
        cell.imageView.image = UIImage(named: imageName)
    }
}
