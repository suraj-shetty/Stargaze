//
//  EventSegmentsViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class EventSegmentsViewModel: ObservableObject {
    @Published var segments: [CelebEventListViewModel]
    var cancellables = [AnyCancellable]()
    
    init(segments: [CelebEventListViewModel]) {
        self.segments = segments
        
        self.segments.forEach({[weak self] in
            let cancellable = $0.objectWillChange
                .sink(receiveValue: { 
                    self?.objectWillChange.send()
                })
            self?.cancellables.append(cancellable)
        })
    }
    
    deinit {
        self.cancellables.forEach{(
            $0.cancel()
        )}
    }
}
