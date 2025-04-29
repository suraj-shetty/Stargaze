//
//  ReportListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 29/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI

struct ReportListView: View {
    @StateObject private var viewModel: ReportListViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var allowReporting: Bool = false
    
    init(userID: Int) {
        let viewModel = ReportListViewModel(userID: userID)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            navView()
            contentView()
            button()
        }
        .background {
            Color.brand2
                .opacity(allowReporting ? 1.0 : 0.5)
                .ignoresSafeArea(.all,
                                 edges: .bottom)
        }
        .toast(isPresented: $viewModel.didReport,
               dismissAfter: 5,
               onDismiss: {
            
            let info = [FeedNotificationKey.listUpdateType : FeedListUpdateType.reported(viewModel.userId)]
            
            NotificationCenter.default.post(name: .feedListUpdated,
                                            object: nil,
                                            userInfo: info)
            self.dismiss()
        }, content: {
            SGSuccessToastView(message: NSLocalizedString("report.submit.success.title",
                                                          comment: ""))
        })
        .toastDimmedBackground(false)
    }
    
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("report.title")
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
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea(.all,
                                 edges: .top)
        }
        .tint(.text1)
    }
    
    private func contentView() -> some View {
        List {
            ForEach(viewModel.options) { option in
                ReportRowView(viewModel: option)
            }
            .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden, edges: .all)
            .listRowBackground(Color.brand1)
        }
        .listStyle(.plain)
        .background(content: {
            Color.brand1
        })
        .cornerRadius(40,
                      corners: [.bottomLeft, .bottomRight])
        .onReceive(viewModel.objectWillChange,
                   perform: { _ in
            withAnimation {
                self.allowReporting = viewModel.canReport()
            }
        })
    }
    
    private func button() -> some View {
        Button {
            viewModel.report()
        } label: {
            Text("report.submit.title")
                .foregroundColor(.darkText)
                .font(.system(size: 15, weight: .medium))
                .kerning(3.53)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
//                .padding(10)
        }
        .disabled(!allowReporting)
        .opacity(allowReporting ? 1.0 : 0.5)

    }
}

struct ReportListView_Previews: PreviewProvider {
    static var previews: some View {
        ReportListView(userID: 0)
    }
}
