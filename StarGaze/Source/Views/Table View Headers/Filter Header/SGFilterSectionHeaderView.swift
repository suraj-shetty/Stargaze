//
//  SGFilterSectionHeaderView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 27/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

class SGFilterSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var `switch`: PWSwitch!
    @IBOutlet weak var switchContentView: UIView!
    
    private let disposeBag = DisposeBag()
    
    unowned var viewModel: SGFilterHeaderViewModel? {
        didSet {
            updateContent()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBinding()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .brand1
        self.backgroundView = backgroundView
    }
}

private extension SGFilterSectionHeaderView {
    func setupBinding() {
        contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe {[weak self] _ in
                let isOn = self?.viewModel?.showDetails ?? false
                self?.viewModel?.showDetails  = !isOn
                
                self?.toggleButton.setImage(!isOn
                                      ? UIImage(named: "filterMinus")
                                      : UIImage(named: "filterPlus"),
                                      for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    func updateContent() {
        titleLabel.text = viewModel?.title
        
        let hasRows = (viewModel?.rows.isEmpty == false)
        toggleButton.isHidden = !hasRows
        switchContentView.isHidden = hasRows
        
        let showDetails = viewModel?.showDetails ?? false
        
        `switch`.setOn(showDetails, animated: false)
        toggleButton.setImage(showDetails
                              ? UIImage(named: "filterMinus")
                              : UIImage(named: "filterPlus"),
                              for: .normal)
    }
}
