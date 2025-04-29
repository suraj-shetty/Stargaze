//
//  SGFilterTableViewCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 30/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

class SGFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchView: PWSwitch!
    
    private let disposeBag = DisposeBag()
    
    unowned var viewModel:SGFilterRowViewModel? {
        didSet {
            updateContent()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupBinding()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .brand1
        self.backgroundView = backgroundView
        
        contentView.backgroundColor = .brand1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

private extension SGFilterTableViewCell {
    func updateContent() {
        let value = viewModel?.didSelect ?? false
        
        titleLabel.text = viewModel?.title
        switchView.setOn(value, animated: false)
    }
    
    func setupBinding() {
        contentView.rx.tapGesture()
            .when(.ended)
            .subscribe {[weak self] _ in
                let value = self?.viewModel?.didSelect ?? false
                
                self?.switchView.setOn(!value, animated: true)
                self?.viewModel?.didSelect = !value
            }
            .disposed(by: disposeBag)
    }
}
