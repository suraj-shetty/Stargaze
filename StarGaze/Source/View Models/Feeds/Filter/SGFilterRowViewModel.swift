//
//  SGFilterRowViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGFilterRowViewModel: NSObject {
    private(set) var filter:SGFilter!
    @PostPublished var didSelect:Bool!
    
    convenience init(filter:SGFilter, didSelect:Bool) {
        self.init()
        self.filter = filter
        self.didSelect = didSelect
    }
    
    var title:String {
        get { return filter.name }
    }
}
