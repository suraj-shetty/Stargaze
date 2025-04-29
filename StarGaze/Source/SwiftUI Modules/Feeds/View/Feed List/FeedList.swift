//
//  FeedList.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Introspect
import Shimmer


struct FeedList<V1, V2>: View where V1: View, V2: View {
    
    @State private var didLoad: Bool = false
    @State private var cancellables = Set<AnyCancellable>()
    @State var scrollOffset: CGPoint = .zero
    
    @State var parentProxy: GeometryProxy
    
    private let content: () -> TupleView<(Top<V1>, Header<V2>)>
    @State private var contentOffsetSubscription: AnyCancellable?
    
    @ObservedObject var segmentList: FeedSegmentsViewModel
    @EnvironmentObject var filterViewModel: FilterListViewModel
    
        
    init(segments:FeedSegmentsViewModel,
         parentProxy:GeometryProxy,
         @ViewBuilder content: @escaping () -> TupleView<(Top<V1>, Header<V2>)>) {
        self.content = content
        self.segmentList = segments
        self._parentProxy = State(initialValue: parentProxy)
    }
    
    
    var body: some View {
        let (top, header) = self.content().value
        return List {
            top
            Section {
                let viewModel = segmentList.segments[segmentList.currentIndex]
                
                if segmentList.segments.count > 1 {
                    segmentedControl()
                }
                
                if viewModel.feeds.isEmpty == false {
                    ForEach (Array(viewModel.feeds.enumerated()),
                             id:\.1.id) { index, feed in
                        cardView(for: feed)
                            .readFrame(space: .global,
                                       onChange: { frame in
                                viewModel.scrollTracker
                                    .trackFrame(frame,
                                                for: index,
                                                inViewSize: parentProxy.size)
                            })
                        
//                            .background(Color.clear
//                                .readFrame(space: .global) { frame in
//                                    viewModel.scrollTracker
//                                        .trackFrame(frame,
//                                                    for: index,
//                                                    inViewSize: parentProxy.size)
//                                })
                            .onAppear {
                                viewModel.scrollTracker
                                    .trackAppeared(at: index)
                            }
                            .onDisappear {
                                viewModel.scrollTracker
                                    .trackDisappeared(at: index)
                            }
                    } //End of ForEach
                    listFooterView()
                }
                else if viewModel.didEnd {
                    noFeedPlaceholder()
                }
                
                else { //isLoading = true
                    ForEach((0..<5), id:\.self ) { _ in
                        cardView(for: .preview)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    }
                }
            } header: {
                header
            }
        }
        
        .modifier(
            ListDidScrollViewModifier(currentOffset: segmentList.segments[segmentList.currentIndex]
                .scrollTracker.currentOffset,
                                      didScroll: { offset in
                                          let viewModel = segmentList.segments[segmentList.currentIndex]
                                          viewModel.scrollTracker.trackContentOffset(offset)
                                      })
        )
        .listStyle(.plain)

//        .environment(\.defaultMinListRowHeight, 20) //minimum row height
        .onChange(of: scrollOffset, perform: { newValue in
            let viewModel = segmentList.segments[segmentList.currentIndex]
            viewModel.scrollTracker.trackContentOffset(newValue)
        })
        .onChange(of: segmentList.currentIndex, perform: { index in
            let viewModel = segmentList.segments[index]
            
            if viewModel.didEnd == false, viewModel.isLoading == false, viewModel.feeds.isEmpty {
                viewModel.fetchFeeds(shouldRefresh: true)
            }
            else {
                viewModel.playVisibleVideo()
            }
        })
        .onAppear {
            let headerBackground = UIView()
            headerBackground.backgroundColor = .brand1
            
            UITableViewHeaderFooterView.appearance().backgroundView = headerBackground
            UITableView.appearance().sectionHeaderTopPadding = 0 //To remove the space between the info header view and the segmented view
//            UITableView.appearance().estimatedRowHeight = 48
                        
            let viewModel = segmentList.segments[segmentList.currentIndex]
            if !viewModel.didEnd, !viewModel.isLoading, viewModel.feeds.isEmpty {
                viewModel.fetchFeeds(shouldRefresh: true)
            }
//            if didLoad == false {
//                didLoad = true
//                
//                let viewModel = segmentList.segments[segmentList.currentIndex]
//                viewModel.fetchFeeds(shouldRefresh: true)
//            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .feedPosted)) { _ in
            let viewModel = segmentList.segments[segmentList.currentIndex]
            viewModel.fetchFeeds(shouldRefresh: true)
        }
//        .onReceive(filterViewModel.$pickedFilters) { output in
//            let viewModel = segmentList.segments[segmentList.currentIndex]
//            viewModel.applyFilter(output)
//        }
        
//        .onChange(of: $segmentList.filters) { result in
//
//        }
    }
        
    private func listFooterView() -> some View {
        let viewModel = segmentList.segments[segmentList.currentIndex]
                            
        if viewModel.didEnd == false, viewModel.feeds.isEmpty == false {
            return AnyView(
                HStack {
                    Spacer()
                    Text("Fetching More…")
                        .foregroundColor(.text1)
                        .font(.system(size: 12, weight: .regular))
                        .opacity(0.7)
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .onAppear {
                            viewModel.fetchFeeds(shouldRefresh: false)
                        }
                        .listRowBackground(Color.brand1)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init())
                    
                    Spacer()
                }
            )
        }
        else {
            return AnyView(EmptyView())
        }
    }
    
    private func segmentedControl() -> some View {
        SegmentedPicker(index: $segmentList.currentIndex,
                        segments: segmentList
            .segments
            .map({
                SGSegmentItemViewModel(title: $0.segmentTitle())
            })
        )
        .frame(height:28)
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .listRowBackground(Color.brand1)
        .listRowSeparator(.hidden)
    }
    
    private func cardView(for feed: SGFeedViewModel) -> some View {
        SGFeedCardView(feed: feed, canViewProfile: false)
            .listRowBackground(Color.brand1)
            .listRowSeparatorTint(.tableSeparator)
            .listRowInsets(.init())
    }
    
    private func noFeedPlaceholder() -> some View {
        PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                              title: "NO_FEED_TITLE".localizedKey,
                                              message: "NO_FEED_DESC".localizedKey))
        .listRowInsets(.init())
        .listRowBackground(Color.brand1)
        .listRowSeparator(.hidden)
        .padding(.horizontal, 25)
    }
    
}
