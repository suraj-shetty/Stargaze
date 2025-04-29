//
//  ReportListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 29/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

class ReportRowViewModel: ObservableObject, Identifiable, Equatable {
    let type: ReportType
    @Published var checked: Bool = false
    
    var id: String {
        get {
            return type.title
        }
    }
    
    
    
    init(type: ReportType) {
        self.type = type
    }
    
    
    static func == (lhs: ReportRowViewModel, rhs: ReportRowViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

class ReportListViewModel: ObservableObject {
    let userId: Int
    private(set) var options: [ReportRowViewModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    @Published var didReport: Bool = false
    
    init(userID: Int) {
        self.userId = userID
        
        var rows = [ReportRowViewModel]()
        for type in ReportType.allCases {
            let row = ReportRowViewModel(type: type)
            row.objectWillChange
                .sink {[weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
                        
            rows.append(row)
        }
        self.options = rows
    }
    
    func canReport() -> Bool {
        let allow = (options.first(where: { $0.checked == true }) != nil )
        return allow
    }
    
    func report() {
        SGAlertUtility.showHUD()
        
        let picked = options.filter({ $0.checked })
        
        SGUserService.report(with: ReportUserRequest(userID: userId,
                                                     reasons: picked.map({ $0.type.title }
                                                                        )
                                                         .joined(separator: ", ")
                                                    ))
        .sink { result in
            switch result {
            case .failure(let error):
                SGAlertUtility.hidHUD()
                SGAlertUtility.showErrorAlert(message: error.description)
                
            case .finished: break
            }
        } receiveValue: {[weak self] didSend in
            SGAlertUtility.hidHUD()
            self?.didReport = didSend
        }
        .store(in: &cancellables)

    }
}
