//
//  CelebEventList.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Combine
import Introspect
import Shimmer

typealias Top<V> = Group<V> where V:View
typealias Header<V> = Group<V> where V:View


struct CelebEventList<V1, V2>: View where V1: View, V2: View {
    
    @State private var didLoad: Bool = false
    @State private var currentSegmentIndex: Int = 0
    @State private var cancellables = Set<AnyCancellable>()
    @State var scrollOffset: CGPoint = .zero
    
    @State var parentProxy: GeometryProxy
    
    private let content: () -> TupleView<(Top<V1>, Header<V2>)>
    @State private var contentOffsetSubscription: AnyCancellable?
    
    @ObservedObject var segmentList: EventSegmentsViewModel
    @Binding var placeholderHeight: CGFloat
        
    init(segments:EventSegmentsViewModel,
         parentProxy:GeometryProxy,
         placeholderHeight: Binding<CGFloat>,
         @ViewBuilder content: @escaping () -> TupleView<(Top<V1>, Header<V2>)>) {
        self.content = content
        
        self.segmentList = segments
        
        self._placeholderHeight = placeholderHeight
        self._parentProxy = State(initialValue: parentProxy)
    }
    
    
    var body: some View {
        let (top, header) = self.content().value
        return List {
            top
            Section {
                let viewModel = segmentList.segments[currentSegmentIndex]
                
                segmentedControl()
                if viewModel.events.isEmpty == false {
                    ForEach (Array(viewModel.events.enumerated()),
                             id:\.1.id) { index, event in
//                        cardView(for: event)

                        cardView(for: event)
                            .background(Color.clear
                                .readFrame(space: .global) { frame in
                                    viewModel.scrollTracker
                                        .trackFrame(frame,
                                                    for: index,
                                                    inViewSize: parentProxy.size)
                                })
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
                    noEventPlaceholder()
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
        .listStyle(.plain)
        .modifier(ListDidScrollViewModifier(didScroll: { offset in
            let viewModel = segmentList.segments[currentSegmentIndex]
            viewModel.scrollTracker.trackContentOffset(offset)
        }))
//        .environment(\.defaultMinListRowHeight, 20) //minimum row height
        .onChange(of: scrollOffset, perform: { newValue in
            let viewModel = segmentList.segments[currentSegmentIndex]
            viewModel.scrollTracker.trackContentOffset(newValue)
        })
        .onChange(of: currentSegmentIndex, perform: { index in
            let viewModel = segmentList.segments[index]
            
            if viewModel.didEnd == false, viewModel.isLoading == false, viewModel.events.isEmpty {
                viewModel.getEvents(refresh: true)
            }
        })
        .onAppear {
            let headerBackground = UIView()
            headerBackground.backgroundColor = .brand1
            
            UITableViewHeaderFooterView.appearance().backgroundView = headerBackground
            UITableView.appearance().sectionHeaderTopPadding = 0 //To remove the space between the info header view and the segmented view
//            UITableView.appearance().estimatedRowHeight = 48
            if didLoad == false {
                didLoad = true
                
                let viewModel = segmentList.segments[currentSegmentIndex]
                viewModel.getEvents(refresh: true)
            }
        }
    }
        
    private func listFooterView() -> some View {
        let viewModel = segmentList.segments[currentSegmentIndex]
                            
        if viewModel.didEnd == false, viewModel.events.isEmpty == false {
            return AnyView(
                Text("Fetching More…")
                    .foregroundColor(.text1)
                    .font(.system(size: 12, weight: .regular))
                    .opacity(0.5)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .onAppear {
                        viewModel.getEvents(refresh: false)
                    }
                    .listRowBackground(Color.brand1)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
            )
        }
        else {
            return AnyView(EmptyView())
        }
    }
    
    private func segmentedControl() -> some View {
        SegmentedPicker(index: $currentSegmentIndex,
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
    
    private func cardView(for event: SGEventViewModel) -> some View {
        EventCardView(event: event)
            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .listRowBackground(Color.brand1)
            .listRowSeparator(.hidden)
    }
    
    private func placeholderView(with image:String,
                                 title:LocalizedStringKey,
                                 message:LocalizedStringKey) -> some View {
        VStack(alignment: .center,
               spacing: 30) {
            Spacer()
            
            Image(image)
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .center,
                   spacing: 10) {
                Text(title)
                    .foregroundColor(.text1)
                    .font(.system(size: 22, weight: .medium))
                    .frame(height:25)
                
                Text(message)
                    .foregroundColor(.text1)
                    .font(.system(size: 16, weight: .regular))
                    .lineSpacing(6)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
               .listRowInsets(.init())
               .listRowBackground(Color.brand1)
               .listRowSeparator(.hidden)
               .padding(.horizontal, 25)
               .frame(maxWidth:UIScreen.main.bounds.width,
                      minHeight:self.placeholderHeight,
                      maxHeight:self.placeholderHeight)
    }
    
    private func noEventPlaceholder() -> some View {
        placeholderView(with: "noFeed",
                        title: "event.list.empty.title".localizedKey,
                        message: "event.list.empty.message".localizedKey)
    }
    
}

//struct CelebEventList_Previews: PreviewProvider {
//    static var previews: some View {
//        CelebEventList()
//    }
//}
