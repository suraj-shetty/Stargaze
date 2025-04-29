//
//  EventHistoryView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 22/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI
import Shimmer
struct EventHistoryView: View {
    @StateObject private var viewModel: EventHistoryGroupViewModel
    
    @State private var viewTimeLine: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    init(type: EventType) {
        var list = [EventHistoryListViewModel(type: .active, eventType: type)]
        
        if let role = SGAppSession.shared.user.value?.role, role == .celebrity {
            list.append(EventHistoryListViewModel(type: .all, eventType: type))
        }
        else {
            list.append(EventHistoryListViewModel(type: .won, eventType: type))
        }
        
        let group = EventHistoryGroupViewModel(group: list)
        _viewModel = StateObject(wrappedValue: group)
    }
    
    
    var body: some View {
        VStack(spacing: 18) {
            navView()
            contentView()
        }
        .background(
            Color.brand1
                .ignoresSafeArea()
        )
        .fullScreenCover(isPresented: $viewTimeLine) {
            EventTimelineList()
        }
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
                
                Button {
                    viewTimeLine = true
                } label: {
                    Image("timeline")
                        .padding(.trailing, 20)
                }

            }
            .tint(.text1)
        }
    }
    
    private func contentView() -> some View {
        VStack(spacing: 30) {
            
            SegmentedPicker(index: $viewModel.index,
                            segments: viewModel.group.map({
                SGSegmentItemViewModel(title: $0.title)
            }))
            .frame(height: 28)
            .padding(.horizontal, 20)
            
//            SegmentedView(selectedIndex: $viewModel.index,
//                          segments: viewModel.group.map({
//                SegmentItemViewModel(title: $0.title,
//                                     iconName: "")
//            }))
            
            if viewModel.group.isEmpty {
                PlaceholderView(info: PlaceholderInfo(image: "noHistory",
                                                      title: "video-call.history.empty.title".localizedKey,
                                                      message: "NO_FEED_DESC".localizedKey))
            }
            
            else {
                listView(for: viewModel.group[viewModel.index])
            }
        }
    }
    
    @ViewBuilder
    private func listView(for listViewModel: EventHistoryListViewModel) -> some View {
        if listViewModel.list.isEmpty {
            if !listViewModel.didEnd {
                VStack(spacing: 20) {
                    ForEach(0..<3) { _ in
                        EventHistoryRow(viewModel: .preview)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    }
                    
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: false)
                .padding(.horizontal, 20)
                .onAppear {
                    if !listViewModel.isLoading {
                        listViewModel.fetch(refresh: true)
                    }
                }
            }
            else {
                emptyPlaceholder(type: listViewModel.type)
            }
        }
        else {
            List {
                ForEach(listViewModel.list, id:\.id) { cellViewModel in
                    EventHistoryRow(viewModel: cellViewModel)
                        .listRowInsets(.init(top: 0,
                                             leading: 20,
                                             bottom: 20,
                                             trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.brand1)
                }
                
                if !listViewModel.didEnd{
                    HStack {
                        Spacer()
                        Text("Fetching More…")
                            .foregroundColor(.text1)
                            .font(.system(size: 12, weight: .regular))
                            .opacity(0.7)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .onAppear {
                                listViewModel.fetch(refresh: false)
                            }
                            .listRowBackground(Color.brand1)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init())
                        
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func emptyPlaceholder(type: EventHistoryListType) -> some View {
        switch type {
        case .active:
            PlaceholderView(info: PlaceholderInfo(image: "noEvents",
                                                  title: "video-call.history.empty.all.events.title".localizedKey,
                                                  message: ""))
        case .won:
            PlaceholderView(info: PlaceholderInfo(image: "noEvents",
                                                  title: "video-call.history.empty.won.events.title".localizedKey,
                                                  message: ""))
        case .timeline:
            PlaceholderView(info: PlaceholderInfo(image: "noHistory",
                                                  title: "video-call.history.empty.title".localizedKey,
                                                  message: ""))
            
        case .all:
            PlaceholderView(info: PlaceholderInfo(image: "noEvents",
                                                  title: "video-call.history.empty.events.title".localizedKey,
                                                  message: ""))
        }
    }
}



struct EventHistoryView_Preview: PreviewProvider {
    static var previews: some View {
        EventHistoryView(type: .videoCall)
    }
}
