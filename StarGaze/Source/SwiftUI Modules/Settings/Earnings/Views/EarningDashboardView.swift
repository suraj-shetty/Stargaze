//
//  EarningDashboardView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 14/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI

struct EarningDashboardView: View {
    @EnvironmentObject private var menuViewModel: SideMenuViewModel
    @State private var showDateRange: Bool = false
    
    @StateObject private var viewModel = EarningInfoViewModel()
    
    var body: some View {
        
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    navView()
                        .zIndex(1)
    //                    .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
                        .padding(.bottom, 12)
                    
                    ZStack {
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                NavigationLink {
                                    EarningHistoryView(viewModel: viewModel)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .navigationBarHidden(true)
                                } label: {
                                    EarningInfoView(title: "earnings.title".localizedKey,
                                                    value: NumberFormatter.currencyFormatter.string(from: NSDecimalNumber(floatLiteral: viewModel.totalEarnings)) ?? "")
                                }
                                
                                NavigationLink {
                                    EarningHistoryView(viewModel: viewModel)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .navigationBarHidden(true)
                                } label: {
                                    EarningInfoView(title: "earnings.pending.title".localizedKey,
                                                    value: NumberFormatter.currencyFormatter.string(from: NSDecimalNumber(floatLiteral: viewModel.pendingEarnings)) ?? "")
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            chartView()
                                .frame(minHeight: 150)
                            
                            LazyHGrid(rows: [
                                GridItem(.fixed(107)),
                                GridItem(.fixed(107))
                            ], spacing: 13) {
                                EarningCardView(type: .show,
                                                value: NumberFormatter.currencyFormatter
                                    .string(from: NSDecimalNumber(floatLiteral: viewModel.showsEarnings)) ?? "")
                                
                                EarningCardView(type: .feed,
                                                value: NumberFormatter.currencyFormatter
                                    .string(from: NSDecimalNumber(floatLiteral: viewModel.postEarnings)) ?? "")
                                
                                EarningCardView(type: .event,
                                                value: NumberFormatter.currencyFormatter
                                    .string(from: NSDecimalNumber(floatLiteral: viewModel.videoCallEarnings)) ?? "")
                                
                                EarningCardView(type: .subscription,
                                                value: NumberFormatter.currencyFormatter
                                    .string(from: NSDecimalNumber(floatLiteral: viewModel.subscriptionEarnings)) ?? "")
                            }
                            .padding(.horizontal, 20)
            //                .padding(.bottom,
            //                         (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0
            //                                         ? 0
            //                                         : 20.0)
                        }
                        .disabled(viewModel.loading)
                        
                        if viewModel.loading {
                            ProgressView()
                                .tint(.text2)
                                .scaleEffect(2.5)
                        }
                    }
                    .background {
                        Color.brand1
                    }
                }
                .background {
                    Color.brand1
                        .ignoresSafeArea()
                }
            }
            .hiddenNavigationBarStyle()
            .background {
                Color.brand1
                    .ignoresSafeArea()
            }
            
            Color.black
                .opacity(showDateRange ? 0.7 : 0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    self.showDateRange.toggle()
                }
            
            BottomCardView(isOpen: $showDateRange,
                           maxHeight: 425) {
                EarningDateRangePicker(option: viewModel.dateRange) { option in
                    self.viewModel.dateRange = option
                    self.showDateRange.toggle()
                }
            }
                           .ignoresSafeArea(.container, edges: .bottom)
        }
        .toast(item: $viewModel.error,
               dismissAfter: 4,
               content: { error in
            SGErrorToastView(message: error.localizedDescription)
        })
        .toastDimmedBackground(false)
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
        .task {
            await viewModel.fetchInfo()
        }
        .onChange(of: viewModel.dateRange) { _ in
            Task.detached {
                await viewModel.fetchInfo()
            }
        }
        .onAppear {
            let headerBackground = UIView()
            headerBackground.backgroundColor = .brand1
            
            UITableViewHeaderFooterView.appearance().backgroundView = headerBackground
            UITableView.appearance().sectionHeaderTopPadding = 0 //To remove the space between the info header view and the segmented view
        }
    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("earnings.nav-bar.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 18,
                                  weight: .medium))
                
                Spacer()
            }
            
            HStack {
                Button {
                    menuViewModel.showMenu = true
                } label: {
                    Image("navBack")
                }
                .frame(width: 49,
                       height: 46)

                Spacer()
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea(.all,
                                 edges: .top)
        }
        .tint(.text1)
    }
    
    private func chartView() -> some View {
        ZStack(alignment: .top) {
            VStack {
                HStack {
                    Text("Activity")
                        .foregroundColor(.text1)
                        .font(.system(size: 16,
                                      weight: .medium))
                    
                    Spacer()
                    
                    Button {
                        self.showDateRange.toggle()
                    } label: {
                        EarningPickedRangeView(pickedRange: viewModel.dateRange)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
}

private struct EarningInfoView: View {
    @State var title: LocalizedStringKey
    @State var value: String
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                
                Text(title)
                    .foregroundColor(.text1)
                    .font(.system(size: 12, weight: .regular))
                    .kerning(1.43)
                    .frame(height: 14)
                    .opacity(0.42)
                    .padding(.bottom, 21)
                
                Spacer()
            }
            
            Text(value)
                .foregroundColor(.text1)
                .font(.system(size: 23, weight: .regular))
                .kerning(-0.14)
                .padding(.bottom, 16)
            
            HStack(alignment: .center, spacing: 12) {
                Text("earnings.view.title")
                    .foregroundColor(.brand2)
                    .font(.system(size: 16, weight: .medium))
                    .kerning(1.9)
                    
                Image("earningViewArrow")
                
                Spacer()
            }
            
        }
        .padding(.init(top: 16,
                       leading: 17,
                       bottom: 18,
                       trailing: 17))
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.earningViewBackground)
                
//                .clipped()
//                .fill(Color.profileInfoBackground
//                    .opacity(colorScheme == .dark ? 0.12 : 1.0
//                            )
//                )
        }
    }
    
}

private struct EarningCardView: View {
    @State var type: EarningType
    @State var value: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Image(type.icon)
                
                Text(type.title)
                    .foregroundColor(.text1)
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 22)
                
                Spacer()
            }
            
            Spacer()
            
            Text("earnings.tile.title")
                .foregroundColor(.text2)
                .font(.system(size: 12, weight: .regular))
                .opacity(0.6)
            
            Text(value)
                .foregroundColor(.text1)
                .font(.system(size: 14, weight: .regular))
                .frame(height: 22)
        }
        .padding(.init(top: 14,
                       leading: 18,
                       bottom: 13,
                       trailing: 18))
        .background {
            RoundedRectangle(cornerRadius: 11)
                .stroke(Color.commentFieldBorder
                    .opacity(colorScheme == .dark
                             ? 1.0 : 0.0),
                        lineWidth: 1)
                .background {
                    Color.profileInfoBackground
                        .opacity(colorScheme == .dark ? 0.12 : 1.0)
                        .cornerRadius(11)
                }
        }
    }
}



struct EarningDashboardView_Previews: PreviewProvider {
    static var previews: some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                EarningCardView(type: .event,
//                                value: "0.00")
//                .frame(height: 107)
//                Spacer()
//
//                EarningInfoView(title: "earnings.title",
//                                value: "10,000")
//            }
//            Spacer()
//        }
//        .background {
//            Color.brand1
//        }
        
        EarningDashboardView()
    }
}
