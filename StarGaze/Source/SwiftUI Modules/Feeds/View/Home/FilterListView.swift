//
//  FilterListView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 23/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct FilterListView: UIViewControllerRepresentable {
    var viewModel: FilterListViewModel
    var onFilterChanged: (([SGFilter]) -> ())
    
    @Environment(\.dismiss) private var dismiss
    
    
    
    typealias UIViewControllerType = SGFeedsFilterViewController
    
    func makeUIViewController(context: Context) -> SGFeedsFilterViewController {
        var datasource = [SGFilterHeaderViewModel]()
        
        for filter in viewModel.datasource {
            let subFilters = filter.subFilters ?? []
            
            if subFilters.isEmpty {
                let didSelect = viewModel.pickedFilters.first(where: { $0.id == filter.id })
                let header = SGFilterHeaderViewModel(filter: filter, rows: [])
                header.showDetails = (didSelect != nil)
                datasource.append(header)
            }
            else {
                var isHeaderSelected: Bool = false
                
                var subViewModels = [SGFilterRowViewModel]()
                for subFilter in subFilters {
                    let isRowSelected = viewModel.pickedFilters
                        .first(where: { $0.id == subFilter.id})
                                        
                    if isRowSelected != nil {
                        isHeaderSelected = true
                    }
                    
                    let row = SGFilterRowViewModel(filter: subFilter,
                                                   didSelect: (isRowSelected != nil))
                    subViewModels.append(row)
                }
                
                let header = SGFilterHeaderViewModel(filter: filter,
                                                     rows: subViewModels)
                header.showDetails = isHeaderSelected
                datasource.append(header)
            }
        }
        
        let vc = SGFeedsFilterViewController(nibName: "SGFeedsFilterViewController",
                                             bundle: nil)
        vc.datasource = datasource
        vc.callback = { updated in
            var picked = [SGFilter]()
            
            for header in updated {
                let hasRows = !header.rows.isEmpty
                
                if hasRows {
                    var subFilters = [SGFilter]()
                    
                    for row in header.rows {
                        if row.didSelect == true {
                            subFilters.append(row.filter)
                        }
                    }
                    
                    picked.append(contentsOf: subFilters)
                }
                else {
                    if header.showDetails {
                        picked.append(header.filter)
                    }
                }
            }
            self.onFilterChanged(picked)
            self.dismiss()
        }
        vc.dismiss = {
            self.dismiss()
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SGFeedsFilterViewController, context: Context) {
    }
}
