//
//  EarningListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 16/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarningListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EarningsListViewModel
    @State var range: EarningDateRangeType
    
    var body: some View {
        ZStack {
            if viewModel.loading {
                VStack {
                    Spacer()
                    
                    ProgressView()
                        .tint(.text1)
                        .scaleEffect(1.5)
                    
                    Spacer()
                }
            }
            else if viewModel.transactions.isEmpty {
                PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                      title: "earnings.list.empty.title",
                                                      message: ""))
            }
            else {
                List {
                    ForEach(viewModel.transactions, id:\.title) { transaction in
                        Section {
                            ForEach(transaction.rows, id:\.id) { row in
                                NavigationLink {
                                    EarningDetailView(info: row)
                                } label: {
                                    EarningListCellView(iconName: row.type.icon,
                                                        titleText: row.title,
                                                        amountText: row.amountText)
                                    .listRowInsets(.init(top: 17,
                                                         leading: 20,
                                                         bottom: 17,
                                                         trailing: 20))
                                    .listRowBackground(Color.brand1)
                                    .listRowSeparator(.hidden, edges: .top)
                                    .listRowSeparatorTint(.profileSeperator, edges: .bottom)
                                }
                            }
                        } header: {
                            EarningSectionHeaderView(title: transaction.title)
                                .listRowBackground(Color.brand1)
                                .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                                .listSectionSeparator(.hidden)
                        }
                        
                        .listSectionSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background {
            Color.brand1
        }
        .onAppear {
            let headerBackground = UIView()
            headerBackground.backgroundColor = .brand1
            
            UITableViewHeaderFooterView.appearance().backgroundView = headerBackground
            UITableView.appearance().sectionHeaderTopPadding = 0 //To remove the space between the info header view and the segmented view
            
            Task.detached {
                await viewModel.fetchTransactions()
            }                        
//                if self.didRequestUpdate == false {
//                    self.didRequestUpdate = true
                
//                }
        }
        .onChange(of: viewModel.range) { newValue in
            Task.detached {
                await viewModel.fetchTransactions()
            }
        }
    }
}

struct EarningListView_Previews: PreviewProvider {
    static var previews: some View {
        EarningListView(viewModel: .init(status: .paid), range: .month)
    }
}
