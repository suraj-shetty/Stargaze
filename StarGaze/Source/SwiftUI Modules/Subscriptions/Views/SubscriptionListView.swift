//
//  SubscriptionListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 19/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Shimmer
import ToastUI

struct SubscriptionListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showContent: Bool = false
    
    @StateObject private var cardState = CarousalStateModel()
    @StateObject private var viewModel = SubscriptionListViewModel()
    
    @State private var pickedPlan: SubscriptionPlanViewModel?
    
    let celeb: Celeb?
    
    init(celeb: Celeb?) {
        self.celeb = celeb
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(showContent ? 0.5 : 0.0)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: showContent)
                .ignoresSafeArea()
            
            ZStack {
                Color.brand1
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(.container, edges: .bottom)
                
                VStack(spacing: 0) {
                    navView()
                        .padding(.vertical, 18)
                    
                    contentView()
                }
            }
            .padding(.top, 61)
            .offset(x: 0, y: showContent ? 0 : UIScreen.main.bounds.height)
            .animation(.easeIn(duration: 0.25), value: showContent)
        }
        .background(
            ClearBackgroundView()
                .ignoresSafeArea()
        )
        .onAppear {
            withAnimation {
                self.showContent = true
            }
            
            viewModel.getPlans(for: celeb?.id)
        }
        .fullScreenCover(item: $pickedPlan) { plan in
            PackageListView(plan: plan) { packageId in
                if let package = pickedPlan?.packages
                    .first(where: { $0.id == packageId }) {
                    viewModel.addPackage(package)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .packageAdded)) { _ in
                self.pickedPlan = nil
                self.dismiss()
        }
        .toast(item: $viewModel.error,
               dismissAfter: 4) { error in
            SGErrorToastView(message: error.localizedDescription)
        }
               .toastDimmedBackground(false)
    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("subscription.list.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        self.showContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withoutAnimation {
                            self.dismiss()
                        }
                    }
                    
                } label: {
                    Image("subscriptionClose")
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        if !viewModel.plans.isEmpty {
            Group {
                cardStackView()
                
                pageControl()
            }
        }
        else if viewModel.isLoading {
            
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        SubscriptionCardView(appearance: .preview,
                                             info: self.cardInfo(for: SubscriptionPlanViewModel.preview)) {
                            
                        }
                                             .frame(width: proxy.size.width - 120)
                                             .redacted(reason: .placeholder)
                                             .shimmering()
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .padding(.bottom, 43)
        }
        else {
            PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                  title: "subscription.list.empty.title".localizedKey,
                                                  message: ""))
        }
    }
    
    private func cardStackView() -> some View {
        GeometryReader { proxy in
            let spacing:            CGFloat = 30
            let widthOfHiddenCards: CGFloat = 30    // UIScreen.main.bounds.width - 10
            let cardHeight:         CGFloat = proxy.size.height - 30
            
            Canvas {
                Carousel(numberOfItems: CGFloat(viewModel.plans.count),
                         spacing: spacing,
                         widthOfHiddenCards: widthOfHiddenCards) {
                    ForEach(Array(viewModel.plans.enumerated()), id:\.1.type) { (index, planViewModel) in
                        Item(_id: index,
                             spacing: spacing,
                             widthOfHiddenCards: widthOfHiddenCards,
                             cardHeight: cardHeight) {
                            VStack(spacing: 0) {
                                
                                Spacer()
                                
                                SubscriptionCardView(appearance: planViewModel.type.cardAppearance(),
                                                     info: cardInfo(for: planViewModel),
                                                     onSelection: {
                                    withoutAnimation {
                                        self.pickedPlan = planViewModel
                                    }
                                })
                                
                                Spacer()
                            }
                            .transition(.slide)
                        }
                    }
                }
                         .environmentObject( self.cardState )
            }
        }
        .padding(.vertical, 15)
    }
    
    private func pageControl() -> some View {
        HStack(alignment: .center,
               spacing: 9) {
            ForEach(Array(viewModel.plans.enumerated()), id:\.offset) { (index, _) in
                Circle()
                    .fill(Color.text1)
                    .opacity(index == cardState.activeCard ? 1.0 : 0.2)
                    .frame(width: (index == cardState.activeCard) ? 10 : 6,
                           height: (index == cardState.activeCard) ? 10 : 6
                    )
            }
        }
               .frame(height: 10)
               .padding(18)
    }
}

struct SubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            SubscriptionListView(celeb: nil)
        }
        .background(Color.white)
        .preferredColorScheme(.dark)
    }
}


extension SubscriptionTypes {
    func cardAppearance() -> SubscriptionCardAppearance {
        switch self {
        case .comments:
            return SubscriptionCardAppearance(iconName: "commentCardIcon",
                                              background: Gradient(colors: [
                                                .init(uiColor: UIColor(rgb: 0x46d9fb)),
                                                .init(uiColor: UIColor(rgb: 0x2f8df4))
                                              ]),
                                              shadow: .init(uiColor: UIColor(rgb: 0x60b3f6)).opacity(0.4)
            )
        case .celebrity:
            return SubscriptionCardAppearance(iconName: "starCardIcon",
                                              background: Gradient(colors: [.liliac, .lightPurple]),
                                              shadow: .lightPurple2.opacity(0.33))
        case .appUnlock:
            return SubscriptionCardAppearance(iconName: "appUnlockIcon",
                                              background: Gradient(colors: [.coralPink, .fadedRed]),
                                              shadow: .watermelon.opacity(0.44))
        }
    }
    
    func index() -> Int {
        switch self {
        case .comments:
            return 0
        case .celebrity:
            return 1
        case .appUnlock:
            return 2
        }
    }
}

private extension SubscriptionListView {
    func cardInfo(for plan: SubscriptionPlanViewModel) -> SubscriptionCardInfo {
        switch plan.type {
        case .appUnlock:
            return SubscriptionCardInfo(title: "Unlock Complete App",
                                        cost: plan.cost,
                                        features: [
                                            "Exclusive content",
                                            "Priority to win the video calls",
                                            "Ability to comment",
                                            "Message the stars privately"
                                           ])
            
        case .celebrity:
            return SubscriptionCardInfo(title: celeb?.name ?? "",
                                        cost: plan.cost,
                                        features: [
                                            "Exclusive content",
                                            "Priority to win the video calls",
                                            "Ability to comment",
                                            "Message the stars privately"
                                           ])
            
        case .comments:
            return SubscriptionCardInfo(title: "Unlock Entire App Comments",
                                        cost: plan.cost,
                                        features: [
                                            "Add free",
                                            "Unlimited comments"
                                           ])
        }
    }
}

extension SubscriptionPlanViewModel {
    static var preview: SubscriptionPlanViewModel {
        get {
            return SubscriptionPlanViewModel(type: .appUnlock,
                                             packages: [],
                                             cost: 100)
        }
    }
}

extension SubscriptionCardAppearance {
    static var preview: SubscriptionCardAppearance {
        return SubscriptionCardAppearance(iconName: "",
                                          background: Gradient(colors: [
                                            .charcoalGrey,
                                            .greyishBrown
                                          ]),
                                          shadow: .black.opacity(0.3))
    }
}
