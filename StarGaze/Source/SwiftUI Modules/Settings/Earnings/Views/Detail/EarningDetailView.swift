//
//  EarningDetailView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 16/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarningDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var info: EarningsRowInfo
    
    var body: some View {
        VStack(spacing: 0) {
            navView()
            
            List {
                row(title: "Title") {
                    EmptyView()
                }
                
                row(title: "Type") {
                    EmptyView()
                }
                
                row(title: "Status") {
                    infoText(title: info.status.rawValue.capitalized,
                             textColor: .text1)
                }
                
                row(title: "Date") {
                    infoText(title: info.dateText,
                             textColor: .text1)
                }
                
                row(title: "Amount") {
                    infoText(title: info.amountText,
                             textColor: .celebBrand)
                }
            }
            .listStyle(.plain)
        }
        .background {
            Color.brand1.ignoresSafeArea()
        }
    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("earnings.detail.title")
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
    
    private func row<Content: View>(title:String, @ViewBuilder info: ()->Content) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(title)
                .foregroundColor(.text2)
                .font(.system(size: 16, weight: .regular))
                .opacity(0.5)
            
            Spacer()
            
            info()
        }
        .listRowInsets(.init(top: 16,
                             leading: 20,
                             bottom: 16,
                             trailing: 20))
        .listRowBackground(Color.brand1)
        .listRowSeparator(.visible, edges: .bottom)
        .listRowSeparatorTint(.profileSeperator,
                              edges: .bottom)
    }
    
    private func infoText(title: String, textColor: Color) -> some View {
        Text(title)
            .foregroundColor(textColor)
            .font(.system(size: 16, weight: .regular))
    }
}

struct EarningDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EarningDetailView(info: .init(transaction: .init(id: 1,
                                                         title: "Sample",
                                                         status: .pending,
                                                         type: .show,
                                                         amount: 1000,
                                                         date: .now)))
    }
}
