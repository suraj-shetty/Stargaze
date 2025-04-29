//
//  SGFilterHeaderViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 28/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGFilterHeaderViewModel: NSObject {
    private(set) var filter:SGFilter!
    
    @PostPublished var showDetails:Bool = false
    
    var rows:[SGFilterRowViewModel]!
    
    convenience init(filter:SGFilter, rows:[SGFilterRowViewModel]) {
        self.init()
        self.filter = filter
        self.rows = rows
    }
    
    var title:String {
        get { return filter.name }
    }
}

extension SGFilterHeaderViewModel {
//    class func mockData() -> [SGFilterHeaderViewModel]{
//        return [
//            SGFilterHeaderViewModel(title: "Entertainment",
//                                    rows: [SGFilterRowViewModel(title: "Drama", didSelect: false),
//                                          SGFilterRowViewModel(title: "Plays", didSelect: false)]),
//            SGFilterHeaderViewModel(title: "Sports", rows: [SGFilterRowViewModel(title: "Sports", didSelect: false),
//                                                            SGFilterRowViewModel(title: "Tennis", didSelect: false)]),
//            SGFilterHeaderViewModel(title: "Movies", rows: [SGFilterRowViewModel(title: "Hollywood", didSelect: false),
//                                                            SGFilterRowViewModel(title: "Bollywood", didSelect: false)]),
//            SGFilterHeaderViewModel(title: "Education", rows: [SGFilterRowViewModel(title: "Maths", didSelect: false)]),
//            SGFilterHeaderViewModel(title: "Film", rows: [SGFilterRowViewModel(title: "Hollywood", didSelect: false),
//                                                            SGFilterRowViewModel(title: "Bollywood", didSelect: false)]),
//            SGFilterHeaderViewModel(title: "Music", rows: [SGFilterRowViewModel(title: "Hollywood", didSelect: false),
//                                                            SGFilterRowViewModel(title: "Bollywood", didSelect: false)]),
//            SGFilterHeaderViewModel(title: "Television", rows: [SGFilterRowViewModel(title: "Hollywood", didSelect: false),
//                                                            SGFilterRowViewModel(title: "Bollywood", didSelect: false)]),
//            SGFilterHeaderViewModel(title: "Culinary", rows: [SGFilterRowViewModel(title: "Hollywood", didSelect: false),
//                                                            SGFilterRowViewModel(title: "Bollywood", didSelect: false)])
//        ]
//    }
}
