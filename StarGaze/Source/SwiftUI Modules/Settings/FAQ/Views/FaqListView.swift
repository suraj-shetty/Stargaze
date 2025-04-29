//
//  FaqListView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 31/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct FaqListView: View {
    @StateObject private var list = FaqListViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    
                    Text("faq.list.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                }
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image("navBack")
                            .tint(Color.text1)
                    }
                    .frame(width: 49, height: 49)

                    Spacer()
                }
            }
            
            List {
                ForEach(list.items, id: \.title) { item in
                    FaqCellView(viewModel: item)
                        .onTapGesture {
                            item.displayInfo.toggle()
                        }
                        .animation(.linear(duration: 0.3), value: item.displayInfo)
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden, edges: .all)
                        .listRowBackground(Color.brand1)
                    
                }
            }
            .listStyle(.plain)
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
    }
}

struct FaqListView_Previews: PreviewProvider {
    static var previews: some View {
        FaqListView()
    }
}
