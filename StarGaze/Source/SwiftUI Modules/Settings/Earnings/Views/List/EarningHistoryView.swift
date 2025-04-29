//
//  EarningHistoryView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 16/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarningHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var pickedIndex: Int = 0
    @State private var showDateRange: Bool = false
    
    private let segments = [
        SegmentItemViewModel(title: EarningStatus.pending.title,
                             iconName: ""),
        SegmentItemViewModel(title: EarningStatus.paid.title,
                             iconName: ""),
        SegmentItemViewModel(title: EarningStatus.support.title,
                             iconName: "")
    ]
    
    @StateObject private var paidListViewModel = EarningsListViewModel(status: .paid)
    @StateObject private var pendingListViewModel = EarningsListViewModel(status: .pending)
    @StateObject private var supportListViewModel = EarningsListViewModel(status: .support)
    @ObservedObject var viewModel: EarningInfoViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navView()
                
                infoView()
                
                SegmentedView(selectedIndex: $pickedIndex,
                              segments: segments,
                              showText: true)
                .padding([.horizontal, .bottom], 20)
                
                switch pickedIndex {
                case 1: contentView(for: .paid)
                case 2: contentView(for: .support)
                default: contentView(for: .pending)
                }
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
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
        .onAppear(perform: {
            paidListViewModel.range = viewModel.dateRange
            pendingListViewModel.range = viewModel.dateRange
            supportListViewModel.range = viewModel.dateRange
        })
        .onChange(of: viewModel.dateRange) { newValue in
            paidListViewModel.range = newValue
            pendingListViewModel.range = newValue
            supportListViewModel.range = newValue
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
                    dismiss()
                } label: {
                    Image("navBack")
                }
                .frame(width: 49,
                       height: 46)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image("filter")
                        .renderingMode(.template)
                        .tint(.text1)
                        .foregroundColor(.text1)
                        .frame(width: 62, height: 46)
                }
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea(.all,
                                 edges: .top)
        }
        .tint(.text1)
    }
    
    @ViewBuilder
    private func contentView(for status: EarningStatus) -> some View {
        switch status {
        case .pending:
            EarningListView(viewModel: pendingListViewModel,
                            range: viewModel.dateRange)
        case .paid:
            EarningListView(viewModel: paidListViewModel,
                            range: viewModel.dateRange)
        case .support:
            EarningListView(viewModel: supportListViewModel,
                            range: viewModel.dateRange)
        }
    }
    
    private func infoView() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            balanceInfoView()
            
            Spacer()
            
            Button {
                self.showDateRange.toggle()
            } label: {
                EarningPickedRangeView(pickedRange: viewModel.dateRange)
            }
        }
        .padding(20)
        
    }
    
    @ViewBuilder
    private func balanceInfoView() -> some View {
        
        VStack(alignment: .leading,
               spacing: 5) {
            Text("\(viewModel.dateRange.title) Earning".capitalized)
                .foregroundColor(.text1)
                .font(.system(size: 16, weight: .regular))
                .opacity(0.6)
            
            switch pickedIndex {
            case 1 :
                Text(paidListViewModel.amountText)
                    .foregroundColor(.text2)
                    .font(.system(size: 22,
                                  weight: .regular))
                
            case 2:
                Text(supportListViewModel.amountText)
                    .foregroundColor(.text2)
                    .font(.system(size: 22,
                                  weight: .regular))
                
            default:
                Text(pendingListViewModel.amountText)
                    .foregroundColor(.text2)
                    .font(.system(size: 22,
                                  weight: .regular))
            }
        }
    }
}

private extension EarningStatus {
    var title: String {
        switch self {
        case .pending:
            return "Pending"
        case .paid:
            return "Paid"
        case .support:
            return "Support"
        }
    }
}

struct EarningHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        EarningHistoryView(viewModel: .init())
    }
}
