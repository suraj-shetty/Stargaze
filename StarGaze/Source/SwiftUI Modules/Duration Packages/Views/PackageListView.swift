//
//  PackageListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 21/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI

enum PackageListLinkType: String, Identifiable {
    var id: Self { self }
    
    case buyCoins = "Buy Coins"
    case terms = "Terms"
    case privacyPolicy = "Privacy Policy"
}

struct PackageListView: View {
    @ObservedObject private var planViewModel: SubscriptionPlanViewModel
    
    @StateObject var viewModel: PackageListViewModel
    @State private var showContent: Bool = false
    @State private var offset: CGSize = .zero
    
    @State private var clickedLink: PackageListLinkType? = nil
    @State private var maxHeight: CGFloat = 120
    
    @Environment(\.dismiss) private var dismiss
    
    let onSelect:((Int)->())
    
    init(plan: SubscriptionPlanViewModel, onSelection: @escaping ((Int)->())) {
        let viewModel = PackageListViewModel()
        viewModel.packages = plan.packages.map({ PackageViewModel(id: $0.id,
                                                                  duration: $0.type.duration,
                                                                  cost: $0.cost,
                                                                  isRecommended: ($0.type == .year))
        })
        
//        viewModel.balance = SGAppSession.shared.wallet.value?.goldCoins ?? 0
        
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSelect = onSelection
        self.planViewModel = plan
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(showContent ? 0.5 : 0.0)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: showContent)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withoutAnimation {
                            self.dismiss()
                        }
                    }
                }
            
            VStack(spacing: 0, content: {
                Spacer()
                
                ZStack {
                    Color.packageBackground
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .ignoresSafeArea(.container, edges: .bottom)
                    
                    VStack(spacing: 0) {
                        navView()
                            .padding(.vertical, 18)
                        
                        contentView()
                    }
                }
            })
            .frame(maxHeight: maxHeight)
            .fixedSize(horizontal: false, vertical: true)
            .offset(x: 0, y: showContent ? 0 : UIScreen.main.bounds.height)
            .animation(.easeIn(duration: 0.25), value: showContent)
            .padding(.top,
                     (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 20)
//            .offset(offset)
//            .gesture(DragGesture()
//                .onChanged({ gesture in
//                    if offset.height >= 0 {
//                        offset = CGSize(width: 0, height: gesture.translation.height)
//                    }
//                })
//                .onEnded({ gesture in
//                    if abs(offset.height) > 100 {
//                        showContent = false
//                    }
//                    else {
//                        offset = .zero
//                    }
//                })
//            )

        }
        .background(
            ClearBackgroundView()
                .ignoresSafeArea()
        )
        .onAppear {
            let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
            self.maxHeight = UIScreen.main.bounds.height - safeArea.top - safeArea.bottom - 20
            
            withAnimation {
                self.showContent = true
            }
        }
        .fullScreenCover(item: $clickedLink) { link in
            switch link {
            case .buyCoins:
                BuyCoinsView()
                
            case .terms:
                WebView(title: NSLocalizedString("package.terms.title",
                                                 comment: ""),
                        url: URL(string: "https://stargaze.ai/terms-and-conditions")!)
                
            case .privacyPolicy:
                WebView(title: NSLocalizedString("package.privacy.policy",
                                                 comment: ""),
                        url: URL(string: "https://stargaze.ai/privacy-policy")!)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .exitPayment)) { _ in
            self.clickedLink = nil
        }
//        .onReceive(NotificationCenter.default.publisher(for: .packageAdded)) { _ in
//            withAnimation {
//                self.showContent = false
//            }
//        }
        

    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("package.list.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        showContent = false
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
    
    private func contentView() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    ForEach(viewModel.packages) { package in
                        cellView(for: package)
                    }
                    
                    Text("package.cancel.msg")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.text1)
                        .opacity(0.48)
                        .frame(height: 22)
                        
                    balanceView()
                    
                    if let picked = viewModel.pickedPackage, picked.cost > viewModel.balance {
                        lowBalanceView()
                            .transition(.opacity)
                    }
                    
                    
                    SGRoundRectButton(title: NSLocalizedString("package.select.title",
                                                               comment: ""), padding: 0,
                                      baseColor: .packageHighlight) {
                        if let picked = self.viewModel.pickedPackage {
                            onSelect(picked.id)
                        }
                    }
                                      .disabled(viewModel.pickedPackage == nil)
                                      .opacity(viewModel.pickedPackage == nil ? 0.5 : 1)
                }
                .padding(.top, 1)
                
                linkView()
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            
//            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func cellView(for package: PackageViewModel) -> some View {
        VStack(alignment: .center, spacing: 0) {
            if package.isRecommended {
                ZStack {
                    Color.packageHighlight
                    Image("packageRecommended")
                }
                .frame(height: 32)
                .cornerRadius(12,
                              corners: [.topLeft, .topRight])
            }
            
            HStack(alignment: .center,
                   spacing: 0) {
                package.durationTitle()
                
                Spacer()
                
                package.costTitle()
            }
                   .padding(.horizontal, 18)
                   .padding(.vertical, 12)
        }
        .background(
            Color.packageCellBackground
                .cornerRadius(12)
        )
        .overlay {
            if viewModel.pickedPackage == package {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.packageHighlight,
                            lineWidth: 2)
            }
            else {
                EmptyView()
            }
        }
        .onTapGesture {
            withAnimation {
                viewModel.pickedPackage = package
            }
        }
    }
    
    private func lowBalanceView() -> some View {
        VStack(alignment: .center, spacing: 14) {
            HStack(alignment: .center, spacing: 7) {
                Image("lowBalance")
                
                Text("package.low.balance.message")
                    .foregroundColor(.lowCoinBalanceText)
                    .font(.system(size: 12, weight: .regular))
                    .lineSpacing(2)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                Color.watermelon
                    .opacity(0.2)
                    .cornerRadius(9)
            )
            
            Button {
                self.clickedLink = .buyCoins
            } label: {
                Text("package.buy.coins.title")
                    .foregroundColor(.packageHighlight)
                    .font(.system(size: 16,
                                  weight: .medium))
                    .underline(true, color: .packageHighlight)
                    .frame(height: 24)
            }
        }
    }
    
    private func balanceView() -> some View {
        HStack(spacing: 0) {
            Text("package.balance.title")
                .foregroundColor(.text1)
                .font(.system(size: 16, weight: .regular))
            
            Spacer()
            
            Text("\(viewModel.balance)")
                .foregroundColor(.packageHighlight)
                .font(.system(size: 18, weight: .medium))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                Color.packageCellBackground
                    .cornerRadius(9)
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.borderGray, style: StrokeStyle(lineWidth:1.2 , lineCap: .round, dash:[5, 5]))
                    .opacity(0.31)
            }
        )
    }
    
    private func linkView() -> some View {
        HStack(spacing: 0) {
            Button {
                self.clickedLink = .terms
            } label: {
                Text("package.terms.title")
                    .foregroundColor(.packageLinkText)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .frame(height: 26)
            }

            Spacer()
            
            Button {
                self.clickedLink = .privacyPolicy
            } label: {
                Text("package.privacy.policy")
                    .foregroundColor(.packageLinkText)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .frame(height: 26)
            }
            
        }
        .padding(.top, 10)
//        .padding(.bottom,
//                 ((UIApplication.shared.keyWindow?
//                    .safeAreaInsets.bottom ?? 0) > 0)
//                 ? 0
//                 : 10
//        )//Push it above for devices like iPhone SE etc
    }
}

extension PackageViewModel {
    @ViewBuilder
    func durationTitle() -> some View {
        if duration < 12 { //In Months
            HStack(spacing: 10) {
                Text("\(duration)")
                    .foregroundColor(.text1)
                    .font(.system(size: 38, weight: .medium))
                
                //                Text("duration.months".formattedString(value: duration))
                Text("duration.months \(duration)")
                .foregroundColor(.text1)
                .opacity(0.36)
                .font(.system(size: 16, weight: .medium))
            }
        }
        else {
            let years = Int(duration / 12)
            
            HStack(spacing: 10) {
                Text("\(years)")
                    .foregroundColor(.text1)
                    .font(.system(size: 38, weight: .medium))
                
                Text("duration.years \(years)")
                .foregroundColor(.text1)
                .opacity(0.36)
                .font(.system(size: 16, weight: .medium))
            }
        }
    }
    
    func costTitle() -> some View {
        return HStack(alignment: .bottom, spacing: 3) {
            Text("\(self.cost)")
                .foregroundColor(.text1)
                .font(.system(size: 18,
                              weight: .medium))
            
            Text("event.coins.count \(self.cost)")
                .foregroundColor(.text1)
                .font(.system(size: 13,
                              weight: .light))
                .padding(.bottom, 1)
        }
    }
}


struct PackageListView_Previews: PreviewProvider {
    static var previews: some View {
        PackageListView(plan: .preview, onSelection: { _ in

        })
            .preferredColorScheme(.light)
    }
}
