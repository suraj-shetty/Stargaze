//
//  LeaderboardPageViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 27/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
class LeaderboardPageViewModel: ObservableObject {
    let types: [LeaderboardOption]!
    @Published private(set) var viewModels: [LeaderboardListViewModel]!
    
    var cancellables = [AnyCancellable]()
    
    init(types: [LeaderboardOption]) {
        self.types = types
        self.viewModels = types.map({ LeaderboardListViewModel(type: $0) })
        
        self.viewModels.forEach({
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
