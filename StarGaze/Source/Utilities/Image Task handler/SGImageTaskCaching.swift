//
//  SGImageTaskCaching.swift
//  StarGaze
//
//  Created by Suraj Shetty on 22/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Kingfisher

class SGImageTaskCaching: NSObject {
    private var tasks = [String: DownloadTask]()
    
    static var shared: SGImageTaskCaching = {
        return SGImageTaskCaching()
    }()
    
    func addTask(_ task:DownloadTask, for url:URL) {
        tasks[url.absoluteString] = task
    }
    
    func getTask(for url:URL) -> DownloadTask? {
        return tasks[url.absoluteString]
    }
    
    func removeTask(for url:URL) {
        tasks.removeValue(forKey: url.absoluteString)
    }
}
