//
//  FeedSegmentsViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 30/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class FeedSegmentsViewModel: ObservableObject {
    @Published var segments: [FeedListViewModel]
    @Published var currentIndex: Int = 0
    
    var cancellables = [AnyCancellable]()
    
    init(segments: [FeedListViewModel]) {
        self.segments = segments
        
        self.segments.forEach({
            let cancellable = $0.objectWillChange
                .sink(receiveValue: {[weak self] in
                    self?.objectWillChange.send()
                })
            self.cancellables.append(cancellable)
        })
    }
    
    deinit {
        self.cancellables.forEach{(
            $0.cancel()
        )}
    }
}
