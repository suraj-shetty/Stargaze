//
//  SGFeedListFooterView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGFeedListFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .brand1
        self.backgroundView = backgroundView
    }

}
