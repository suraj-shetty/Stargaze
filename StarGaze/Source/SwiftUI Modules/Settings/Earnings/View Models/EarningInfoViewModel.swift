//
//  EarningInfoViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import Foundation
import SwiftDate

class EarningInfoViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var info: EarningsInfo? = nil
    @Published var dateRange: EarningDateRangeType = .month
    @Published var status: EarningStatus = .paid
    @Published var error: SGAPIError? = nil
    
    private let apiClient = SGUserService()
    
    var totalEarnings: Double {
        get {
            guard let info = info
            else { return 0 }
            
            return info.shows + info.videoCalls + info.posts + info.subscriptions
        }
    }
    
    var pendingEarnings: Double {
        return info?.pending ?? 0.0
    }
    
    var showsEarnings: Double {
        return info?.shows ?? 0
    }
    
    var videoCallEarnings: Double {
        return info?.videoCalls ?? 0
    }
    
    var postEarnings: Double {
        return info?.posts ?? 0
    }
    
    var subscriptionEarnings: Double {
        return info?.subscriptions ?? 0
    }
    
        
    @MainActor
    func fetchInfo() async {
        self.loading = true
        
        let response = await apiClient.earnings()
        switch response {
        case .success(let success):
            let result = success.result
            self.info = result
            
        case .failure(let failure):
            self.error = failure
        }
        
        self.loading = false
    }
}


extension EarningDateRangeType {
    var startDate: String {
        let date = Date()
        
        switch self {
        case .month:
            let startDate = date.dateAtStartOf(.month)
            return startDate.toFormat("yyyy-MM-dd")
            
        case .quarter:
            let startDate = (date - 3.months).dateAtStartOf(.month)
            return startDate.toFormat("yyyy-MM-dd")
            
        case .halfYear:
            let startDate = (date - 6.months).dateAtStartOf(.month)
            return startDate.toFormat("yyyy-MM-dd")
            
        case .year:
            let startDate = (date - 1.years).dateAtStartOf(.month)
            return startDate.toFormat("yyyy-MM-dd")
        }
    }
    
    var endDate: String {
        let endDate = Date().dateAtEndOf(.month)
        return endDate.toFormat("yyyy-MM-dd")
    }
}
