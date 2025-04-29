//
//  EventTimelineList.swift
//  StarGaze
//
//  Created by Suraj Shetty on 25/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Shimmer
import Introspect

struct EventTimelineList: View {
    @StateObject private var viewModel =  EventTimelineListViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @State private var offset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 18) {
            navView()
            //noHistory
            contentView()
        }
        .background(
            Color.brand1
                .ignoresSafeArea()
        )
    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("video-call.history.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
            }
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image("navBack")
                }
                .frame(width: 49, height: 44)

                Spacer()
            }
            .tint(.text1)
        }
    }
    
    private func emptyPlaceholder() -> some View {
        PlaceholderView(info: PlaceholderInfo(image: "noHistory",
                                              title: "video-call.history.empty.title".localizedKey,
                                              message: ""))
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        if viewModel.timeline.isEmpty {
            if !viewModel.didEnd {
                VStack(spacing: 20) {
                    ForEach(0..<3) { _ in
                        EventTimelineCell(viewModel: .preview)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    }
                    
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: false)
                .padding(.trailing, 20)
                .onAppear {
                    if !viewModel.isLoading {
                        viewModel.fetch(refresh: true)
                    }
                }
            }
            else {
                emptyPlaceholder()
            }
        }
        else {
            List {
                ForEach(viewModel.timeline, id:\.id) { cellViewModel in
                    EventTimelineCell(viewModel: cellViewModel)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
                
                if !viewModel.didEnd{
                    HStack {
                        Spacer()
                        Text("Fetching More…")
                            .foregroundColor(.text1)
                            .font(.system(size: 12, weight: .regular))
                            .opacity(0.7)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .onAppear {
                                viewModel.fetch(refresh: false)
                            }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                }
            }
            .coordinateSpace(name: "list")
            .listStyle(.plain)
            
            //                .modifier(
            //                    ListDidScrollViewModifier(currentOffset: .zero,
            //                                              didScroll: { offset in
            //                                                  self.offset = offset
            //                                                  print("\(offset)")
            //                                              })
            //                )
            //                .readSize(onChange: { size in
            //                        print("Content Size \(size)")
            //                    if size.height != contentSize.height {
            //                        self.contentSize = size
            //                    }
            //                })
            
        }
    }
}

struct EventTimelineList_Previews: PreviewProvider {
    static var previews: some View {
        EventTimelineList()
    }
}
