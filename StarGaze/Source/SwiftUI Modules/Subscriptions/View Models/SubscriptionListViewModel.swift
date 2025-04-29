//
//  SubscriptionListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 30/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

struct SubscriptionPackageViewModel: Identifiable {
    let id: Int
    let type: SubscriptionPackageType
    let planType: SubscriptionTypes
    let celebID: Int
    let cost: Int
}

class SubscriptionPlanViewModel: ObservableObject, Identifiable {
    let type: SubscriptionTypes
    let packages: [SubscriptionPackageViewModel]
    let cost: Int
    
    var id: String {
        return type.rawValue
    }
    
    init(type: SubscriptionTypes, packages:[SubscriptionPackageViewModel], cost: Int) {
        self.type = type
        self.packages = packages
        self.cost = cost
    }
}

class SubscriptionListViewModel: ObservableObject {
    var plans: [SubscriptionPlanViewModel] = []
    var isLoading: Bool = false
    var error: SGAPIError? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var didAdd: Bool = false
    
    
    func getPlans(for celebID: Int?) {
        self.isLoading = true
        self.objectWillChange.send()
        
        var request: SubscriptionPlanRequest? = nil
        if let id = celebID {
            request = SubscriptionPlanRequest(celebID: id)
        }
        
        SubscriptionServices.getPlans(request: request)
            .sink {[weak self] result in
                switch result {
                case .finished:
                    break
                    
                case .failure(let error):
                    self?.isLoading = false
                    self?.error = error
                    self?.objectWillChange.send()
                }
            } receiveValue: {[weak self] plans in
                let filtered = plans.filter({ $0.type != .appUnlock }) //Removed the whole app unlock package
                
                var viewModels = filtered.map { plan in
                    
                    var packageList = [SubscriptionPackageViewModel]()
                    
                    if let packages = plan.packages, !packages.isEmpty {
                        packageList = packages.map { package in
                            return SubscriptionPackageViewModel(id: package.id,
                                                                type: package.type,
                                                                planType: plan.type,
                                                                celebID: Int(package.celebID) ?? 0,
                                                                cost: package.charges)
                        }
                        
                        packageList.sort { lhs, rhs in
                            return lhs.cost < rhs.cost
                        }
                    }
                                                                                
                    let minPlanCost = packageList.first(where: { $0.type == .month })?.cost ?? packageList.first?.cost
                    
                    return SubscriptionPlanViewModel(type: plan.type,
                                                     packages: packageList,
                                                     cost: minPlanCost ?? 0)
                }
                
                viewModels.removeAll { viewModel in
                    return viewModel.packages.isEmpty
                }
                
                self?.isLoading = false
                self?.plans = viewModels
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func addPackage(_ package: SubscriptionPackageViewModel) {
        if package.planType == .celebrity {
            let request = CelebSubscriptionRequest(celebID: package.celebID,
                                                   typeID: package.id,
                                                   autoRenew: false,
                                                   desc: "Membership is purchased")
            addCelebSubscription(with: request)
        }
        else {
            let request = AppSubScriptionRequest(type: (package.planType == .comments) ? .comment : .appUnlock,
                                                 duration: package.type,
                                                 coin: package.cost,
                                                 desc: "Membership is purchased")
            addAppSubscription(with: request)
        }
    }
    
    private func addAppSubscription(with request: AppSubScriptionRequest) {
        SGAlertUtility.showHUD()
        
        Task.detached {
            let result = await SubscriptionServices.shared.addAppSubscription(with: request)
            switch result {
            case .success(_):
                let subscriptions = await SubscriptionServices.shared.getList()
                switch subscriptions {
                case .success(let success):
                    SGAppSession.shared.subscriptions.send(success.result)
                    
                    DispatchQueue.main.async {
                        SGAlertUtility.hidHUD()
                //        self.didAdd = true
                        NotificationCenter.default.post(name: .packageAdded, object: nil)
                    }
                    
                case .failure(let failure):
                    await self.showError(failure)
                }
                                
            case .failure(let failure):
                await self.showError(failure)
            }
        }
    }
    
    private func addCelebSubscription(with request: CelebSubscriptionRequest) {
        SGAlertUtility.showHUD()
        
        Task.detached {
            let result = await SubscriptionServices.shared.addCelebSubscription(with: request)
            switch result {
            case .success(_):
                let subscriptions = await SubscriptionServices.shared.getList()
                switch subscriptions {
                case .success(let success):
                    SGAppSession.shared.subscriptions.send(success.result)
                    
//                    await self.handleSubscriptionSuccess()
                    DispatchQueue.main.async {
                        SGAlertUtility.hidHUD()
                //        self.didAdd = true
                        NotificationCenter.default.post(name: .packageAdded, object: nil)
                    }
                    
                                        
                case .failure(let failure):
                    await self.showError(failure)
                }
                                
            case .failure(let failure):
                await self.showError(failure)
            }
        }
    }
    
    @MainActor
    private func showError(_ error: SGAPIError) async {
        SGAlertUtility.hidHUD()
        self.error = error
    }
    
    @MainActor
    private func handleSubscriptionSuccess() async {
        SGAlertUtility.hidHUD()
//        self.didAdd = true
        NotificationCenter.default.post(name: .packageAdded, object: nil)
        
    }
    
}
