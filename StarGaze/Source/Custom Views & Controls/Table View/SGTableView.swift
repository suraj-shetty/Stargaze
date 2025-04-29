//
//  SGTableView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 17/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGTableView: UITableView {

    weak var proxyDatasource:UITableViewDataSource?
    weak var proxyDelegate:UITableViewDelegate?
    

    func prepareForPlaceholder() {
        proxyDatasource = dataSource
        proxyDelegate =  delegate
    }
    
    
    func hidePlaceholder() {
        self.backgroundView = nil
        self.dataSource = proxyDatasource
        self.delegate = proxyDelegate
    }
    
    func showFeedLoader() {
        let placeholder = Bundle.main.loadNibNamed("SGFeedLoaderView", owner: nil)?.first as? SGFeedLoaderView
        placeholder?.backgroundColor = .brand1
        
        self.backgroundView = placeholder
        placeholder?.layoutIfNeeded()
        
        proxyDatasource = dataSource
        proxyDelegate = delegate
        dataSource = nil
        delegate = nil
        reloadData()
    }
    
    
    func showNoFeedPlaceholder() {
        let placeholder = Bundle.main.loadNibNamed("SGInfoPlaceholderView", owner: nil)?.first as? SGInfoPlaceholderView
        placeholder?.configure(with: SGPlaceholderViewModel(title: NSLocalizedString("NO_FEED_TITLE", comment: ""),
                                                            desc: NSLocalizedString("NO_FEED_DESC", comment: ""),
                                                            iconName: "noFeed"))
        self.backgroundView = placeholder
        placeholder?.layoutIfNeeded()
        
        proxyDatasource = dataSource
        proxyDelegate = delegate
        dataSource = nil
        delegate = nil
        reloadData()
    }

}
