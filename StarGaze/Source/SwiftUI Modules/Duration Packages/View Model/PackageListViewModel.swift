//
//  PackageListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 21/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class PackageListViewModel: ObservableObject {
    @Published var packages = [PackageViewModel]()
    @Published var balance: Int = 0
    
    @Published var pickedPackage: PackageViewModel? = nil
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        balance = SGAppSession.shared.wallet.value?.goldCoins ?? 0
        
        SGAppSession.shared.wallet
            .sink {[weak self] wallet in
                self?.balance = wallet?.goldCoins ?? 0
            }
            .store(in: &cancellable)
    }
}

extension PackageListViewModel {
    static var preview: PackageListViewModel = {
        let list:[PackageViewModel] = [
            PackageViewModel(id: 0,
                             duration: 1,
                             cost: 1,
                             isRecommended: false),
            PackageViewModel(id: 1,
                             duration: 3,
                             cost: 83,
                             isRecommended: false),
            PackageViewModel(id: 2,
                             duration: 6,
                             cost: 500,
                             isRecommended: false),
            PackageViewModel(id: 3,
                             duration: 12,
                             cost: 1000,
                             isRecommended: true)
        ]
        
        var viewModel = PackageListViewModel()
        viewModel.packages = list
        viewModel.balance = 100
        
        return viewModel
    }()
}
