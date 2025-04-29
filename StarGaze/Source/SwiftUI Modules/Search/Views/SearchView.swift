//
//  SearchView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 27/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Introspect
import Shimmer
import Combine

enum SearchOptions: String {
    case feeds = "Feeds"
    case celebrities = "Celebrities"
    case events = "events"
}

extension SearchOptions {
    var title: String {
        switch self {
        case .feeds:
            return "Feeds"
            
        case .celebrities:
            return "Profiles"
            
        case .events:
            return "Video Calls"
        }
    }
}

struct SearchView: View {
    
    private let options: [SearchOptions] = [.feeds, .celebrities, .events]
    
    private let segments: [SegmentItemViewModel] = [
        SegmentItemViewModel(title: SearchOptions.feeds.title,
                             iconName: ""),
        SegmentItemViewModel(title: SearchOptions.celebrities.title,
                             iconName: ""),
        SegmentItemViewModel(title: SearchOptions.events.title,
                             iconName: "")
    ]
    
    @State private var searchText: String = ""
    @State private var pickedIndex: Int = 0
    @State private var trackDrag: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focussed: Bool
    
    @StateObject private var feedList = FeedSearchViewModel()
    @StateObject private var celebList = CelebritySearchViewModel()
    @StateObject private var eventList = EventSearchViewModel()
    @StateObject private var viewState = ViewState()
    
    @State private var pickedCelebrity: SGCelebrityViewModel?
    
    private let searchSubject = PassthroughSubject<String, Never>()
    private var searchCancellable: AnyCancellable?
    
    init() {
//        searchCancellable = searchSubject
//            .debounce(for: .seconds(3), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .map({ (string) -> String? in
//                if string.count < 3 {
//                    return nil
//                }
//
//                return string
//            })
//            .compactMap({ $0 })
//            .sink {[self] search in
//                print("Text to search \(search)")
//                self.search(for: search)
//            }
        
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar()
            
            if searchText.count < 3 {
                Spacer()
            }
            else {
                SegmentedView(selectedIndex: $pickedIndex,
                              segments: segments,
                              showText: true)
//                .frame(height: 50)
                
                switch pickedIndex {
                case 1: contentView(.celebrities)
                case 2: contentView(.events)
                default: contentView(.feeds)
                }
                
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
        .onDisappear {
            viewState.isVisible = false
        }
        .onAppear {
            viewState.isVisible = true
        }
        .onChange(of: searchText) { newValue in
            search(for: newValue)
        }
        .onChange(of: pickedIndex) { _ in
            search(for: searchText)
        }
    }
    
    private func searchBar() -> some View{
        HStack(spacing: 0) {
            Button {
                focussed = false
                dismiss()
            } label: {
                Image("navBack")
                    .tint(.text1)
                    .frame(width: 45)
            }
            
            ZStack {
                if searchText.isEmpty {
                    HStack(spacing: 12) {
                        Image("searchEvent")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .aspectRatio(contentMode: .fit)
                            .tint(Color.text1)
                        
                        Text("search.field.placeholder.text")
                            .foregroundColor(.text1)
                            .font(.system(size: 16,
                                          weight: .regular))
                        
                        Spacer()
                    }
                    .opacity(0.6)
                }
                
                HStack(spacing: 0) {
                    TextField(text: $searchText) {
                        EmptyView()
                    }
                    .focused($focussed)
                    .foregroundColor(.text1)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button {
                            self.searchText = ""
                        } label: {
                            Image("clear")
                                .frame(width: 20,
                                       height: 20)
                                .tint(.text1)
                        }
                        .frame(width: 52)
                        
                    }
                }
            }
            .padding(.leading, 20)
            .frame(height: 50)
            .background {
                Color.text1
                    .opacity(0.06)
                    .cornerRadius(16)
            }
        }
        
        .padding(EdgeInsets(top: 10,
                            leading: 2,
                            bottom: 5, trailing: 20))
        .background {
            Color.brand1
                .ignoresSafeArea(.all,
                                 edges: .top)
        }
    }
    
    @ViewBuilder
    private func contentView(_ type: SearchOptions) -> some View {
        switch type {
        case .feeds:
            feedListView()
//                .id(searchText)
        case .celebrities:
            celebrityList()
        case .events:
            eventListView()
        }
    }
    
    private func feedListView() -> some View {
        GeometryReader { proxy in
            List {
                if feedList.feeds.isEmpty == false {
                    ForEach (Array(feedList.feeds.enumerated()),
                             id:\.1.id) { index, feed in
                        cardView(for: feed)
                        //                            .id(index)
                            .transition(.move(edge: .top))
                            .readFrame(space: .global,
                                       onChange: { frame in
                                feedList.scrollTracker
                                    .trackFrame(frame,
                                                for: index,
                                                inViewSize: proxy.size)
                            })
                            .onAppear {
                                feedList.scrollTracker
                                    .trackAppeared(at: index)
                            }
                            .onDisappear {
                                feedList.scrollTracker
                                    .trackDisappeared(at: index)
                            }
                    } //End of ForEach
                    
                    if !feedList.didEnd {
                        HStack {
                            Spacer()
                            Text("Fetching More…")
                                .foregroundColor(.text1)
                                .font(.system(size: 12, weight: .regular))
                                .opacity(0.7)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                                .onAppear {
                                    feedList.loadNext()
                                }
                                .listRowBackground(Color.brand1)
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init())
                            
                            Spacer()
                        }
                    }
                }
                else if feedList.didEnd {
                    PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                          title: "NO_FEED_TITLE".localizedKey,
                                                          message: "NO_FEED_DESC".localizedKey))
                    .listRowInsets(.init())
                    .listRowBackground(Color.brand1)
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, 25)
                }
                
                else { //isLoading = true
                    ForEach((0..<5), id:\.self ) { _ in
                        cardView(for: .preview)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    }
                    .disabled(true)
//                    .onAppear {
//                        feedList.load(with: searchText, refresh: false)
//                    }
                }
                
//                else { //Show empty view
//                    VStack {
//                        Spacer()
//                    }
//                    .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
//                    .listRowSeparator(.hidden)
//                    .listRowBackground(Color.brand1)
//                }
            }
            .modifier(
                ListDidScrollViewModifier(currentOffset: feedList.scrollTracker.currentOffset,
                                          didScroll: { offset in
                                              feedList.scrollTracker.trackContentOffset(offset)
//                                              self.focussed = false
                                          })
            )
            .listStyle(.plain)
            .transition(.move(edge: .top))
            .environmentObject(viewState)
            .gesture(DragGesture()
                .onChanged({ value in
                    if abs(value.translation.height) > 0 {
                        focussed = false
                    }
                }))
            //            .onAppear {
            //
            //                if !listViewModel.didEnd, !listViewModel.isLoading, listViewModel.feeds.isEmpty {
            //                    listViewModel.fetchFeeds(shouldRefresh: true)
            //                }
            //            }
            /*
             .onChange(of: scrollOffset, perform: { newValue in
             let viewModel = segmentList.segments[segmentList.currentIndex]
             viewModel.scrollTracker.trackContentOffset(newValue)
             })
             */
        }
    }
    
    private func celebrityList() -> some View {
        List {
            if celebList.celebrities.isEmpty == false {
                
                ForEach(celebList.celebrities) { celebrity in
                    celebCellView(for: celebrity)
                        .onTapGesture {
                            self.focussed = false
                            self.pickedCelebrity = celebrity
                        }
                }//End of ForEach
                
                if !celebList.didEnd {
                    HStack {
                        Spacer()
                        Text("Fetching More…")
                            .foregroundColor(.text1)
                            .font(.system(size: 12, weight: .regular))
                            .opacity(0.7)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .onAppear {
                                celebList.loadNext()
                            }
                        Spacer()
                    }
                    .listRowBackground(Color.brand1)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                }
            }
            else if celebList.didEnd {
                PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                      title: "celebrity.list.empty.title",
                                                      message: "celebrity.list.empty.description"))
                .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.brand1)
            }
            
            else { //isLoading = true
                ForEach((0..<5), id:\.self ) { _ in
                    celebCellView(for: .preview)
                        .redacted(reason: .placeholder)
                        .shimmering()
                }
                .disabled(true)
            }
            
//            else { //Show empty view
//                VStack {
//                    Spacer()
//                }
//                .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
//                .listRowSeparator(.hidden)
//                .listRowBackground(Color.brand1)
//            }
        }
        .listStyle(.plain)
//        .transition(.move(edge: .top))
        .environmentObject(viewState)
        .gesture(DragGesture()
            .onChanged({ value in
                if abs(value.translation.height) > 0 {
                    focussed = false
                }
            }))
        .fullScreenCover(item: $pickedCelebrity) { celebrity in
            SGCelebrityDetailView(celebrity: celebrity)
        }
    }
    
    private func eventListView() -> some View {
        List {
            if eventList.events.isEmpty == false {
                
                ForEach(eventList.events) { eventViewModel in
                    eventCell(for: eventViewModel)
                }//End of ForEach
                
                if !eventList.didEnd {
                    HStack {
                        Spacer()
                        Text("Fetching More…")
                            .foregroundColor(.text1)
                            .font(.system(size: 12, weight: .regular))
                            .opacity(0.7)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .onAppear {
                                eventList.loadNext()
                            }
                        Spacer()
                    }
                    .listRowBackground(Color.brand1)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                }
            }
            else if eventList.didEnd {
                PlaceholderView(info: PlaceholderInfo(image: "noFeed",
                                                      title: "event.list.empty.title",
                                                      message: "event.list.empty.message"))
                .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.brand1)
            }
            
            else { //isLoading = true
                ForEach((0..<5), id:\.self ) { _ in
                    eventCell(for: .preview)
                        .redacted(reason: .placeholder)
                        .shimmering()
                }
                .disabled(true)
            }
        }
        .listStyle(.plain)
//        .transition(.move(edge: .top))
        .gesture(DragGesture()
            .onChanged({ value in
                if abs(value.translation.height) > 0 {
                    focussed = false
                }
            }))
    }
    
    private func cardView(for feed: SGFeedViewModel) -> some View {
        SGFeedCardView(feed: feed)
            .listRowBackground(Color.brand1)
            .listRowSeparatorTint(.tableSeparator)
            .listRowInsets(.init())
    }
    
    private func celebCellView(for celebrity:SGCelebrityViewModel) -> some View {
        SGCelebCellView(viewModel: celebrity)
            .frame(height:56)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .listRowBackground(Color.brand1)
            .listRowSeparator(.hidden)
            .listRowInsets(.init())
    }
    
    private func eventCell(for event: SGEventViewModel) -> some View {
        EventCardView(event: event)
            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .listRowBackground(Color.brand1)
            .listRowSeparator(.hidden)
    }
    
    //MARK: -
    private func search(for text: String) {
//        guard newValue.count > 2
//        else { return }
        
        switch pickedIndex {
        case 1: celebList.searchSubject.send(text)
        case 2: eventList.searchSubject.send(text)
        default: feedList.searchSubject.send(text) //feedList.load(with: text)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
