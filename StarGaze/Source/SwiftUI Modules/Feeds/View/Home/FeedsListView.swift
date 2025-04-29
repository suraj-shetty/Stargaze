//
//  FeedsListView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI
import Shimmer
import Introspect

struct FeedsListView: View {
    @ObservedObject var viewModel: FeedsViewModel
    @ObservedObject var uploadManager: FeedUploadManager
    @State private var createPost: Bool = false
    @State private var loadSearch: Bool = false
    @State private var showBlockAlert: Bool = false
    @State private var inputName: Bool = false
    
    init(viewModel: FeedsViewModel) {
        self.viewModel = viewModel
        self.uploadManager = FeedUploadManager.shared
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .top) {
                contentView(proxy: proxy)
                    .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
                
                if viewModel.feeds.newPostAvailable {
                    
                    Button {
                        let listViewModel = viewModel.filteredFeeds ?? viewModel.feeds
                        if let firstFeedID = listViewModel?.feeds.first?.id {
                            withAnimation {
                                proxy.scrollTo(firstFeedID)
                            }
                        }
                        withAnimation {
                            viewModel.feeds.showNewPosts()
                        }
                        
                    } label: {
                        NewPostToastView()
                    }
                    .buttonStyle(.borderless)
                    .padding(.top, 73)
                    .transition(.move(edge: .top))
                    .animation(.spring(),
                               value: viewModel.feeds.newPostAvailable)
                }
                
            }
        }
        .background(
            Color.brand1
                .ignoresSafeArea()
        )
        .toast(isPresented: $showBlockAlert, dismissAfter: 4) {
            SGSuccessToastView(message: "Celebrity is blocked")
        }
        .toastDimmedBackground(false)
    }
        
    
    //MARK: -
    @ViewBuilder
    private func contentView(proxy: ScrollViewProxy) -> some View {
        VStack {
            HStack(alignment:.center) {
                Button {
                    self.viewModel.showFilter = true
                } label: {
                    Image("filter")
                        .renderingMode(.template)
                        .tint(.text1)
                        .frame(width: 62, height: 44)
                }
                
                Spacer()
                
                Text("feeds.title".localizedKey)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.text1)
                
                Spacer()
                
                Button {
                    loadSearch = true
                } label: {
                    Image("searchEvent")
                        .renderingMode(.template)
                        .tint(.text1)
                        .frame(width: 58, height: 44)
                }
            }
            .background(Color.brand1)
            
            if uploadManager.hasRequest {
                uploadStatusView()
            }
            
            if let filteredFeedsViewModel = viewModel.filteredFeeds {
                feedList(for: filteredFeedsViewModel, scrollProxy: proxy)
            }
            else {
                feedList(for: viewModel.feeds, scrollProxy: proxy)
            }
        }
        .background(
            Color.brand1
                .ignoresSafeArea(.container, edges: .top)
        )
        .fullScreenCover(isPresented: $createPost) {
            SGCreateFeedView()
        }
        .fullScreenCover(isPresented: $viewModel.showFilter, content: {
            FilterListView(viewModel: viewModel.filterList,
                           onFilterChanged: { picked in
                applyFilters(picked)
            })
            .edgesIgnoringSafeArea(.vertical)
        })
        .fullScreenCover(isPresented: $loadSearch,
                         content: {
            SearchView()
        })
        .fullScreenCover(isPresented: $inputName) {
            NameInputView()
        }
        .onDisappear {
            viewModel.viewState.isVisible = false
        }
        .onAppear {
            viewModel.viewState.isVisible = true
            if viewModel.filterList.datasource.isEmpty {
                viewModel.filterList.fetchFilters()
            }
            
            let userName = SGAppSession.shared.user.value?.name ?? ""
            if userName.isEmpty {
                withoutAnimation {
                    self.inputName = true //Show sheet to input user name
                }
            }
            else {
                if let filteredFeedsViewModel = viewModel.filteredFeeds {
                    filteredFeedsViewModel.playVisibleVideo()
                }
                else {
                    viewModel.feeds.playVisibleVideo()
                }
            }
        }
        .onChange(of: createPost) { newValue in
            viewModel.viewState.isVisible = !newValue
        }
        .onChange(of: viewModel.showFilter) { newValue in
            viewModel.viewState.isVisible = !newValue
        }
        .onChange(of: loadSearch, perform: { newValue in
            viewModel.viewState.isVisible = !newValue
        })
        .onChange(of: inputName, perform: { newValue in
            viewModel.viewState.isVisible = !newValue
        })
        .onReceive(NotificationCenter.default
            .publisher(for: .menuWillShow)
        ) { _ in
            viewModel.viewState.isVisible = false
        }
        .onReceive(NotificationCenter.default
            .publisher(for: .menuDidHide)
        ) { _ in
            viewModel.viewState.isVisible = true
            
            let listViewModel = viewModel.filteredFeeds ?? viewModel.feeds
            listViewModel?.scrollTracker.identifyMostVisibleElement()
        }
        .onReceive(NotificationCenter.default
            .publisher(for: .celebrityBlocked)
        ) { _ in
            self.showBlockAlert = true
        }        
        .onChange(of: viewModel.feed) { newValue in
            viewModel.viewState.isVisible = (newValue == nil)
        }
        .fullScreenCover(item: $viewModel.feed) { feed in
            SGMediaPreviewView(viewModel: feed)
        }
    }
    
    
    @ViewBuilder
    private func feedList(for listViewModel: FeedListViewModel, scrollProxy: ScrollViewProxy) -> some View {
        GeometryReader { proxy in
            List {
                addFeedView()
                
                if listViewModel.feeds.isEmpty == false {
                    ForEach (Array(listViewModel.feeds.enumerated()),
                             id:\.1.id) { index, feed in
                        cardView(for: feed)
//                            .id(index)
                            .transition(.move(edge: .top))
                            .readFrame(space: .global,
                                       onChange: { frame in
                                listViewModel.scrollTracker
                                    .trackFrame(frame,
                                                for: index,
                                                inViewSize: proxy.size)
                            })
                            .onAppear {
                                listViewModel.scrollTracker
                                    .trackAppeared(at: index)
                            }
                            .onDisappear {
                                listViewModel.scrollTracker
                                    .trackDisappeared(at: index)
                            }
                    } //End of ForEach
                    listFooterView(for: listViewModel)
                }
                else if listViewModel.didEnd {
                    noFeedPlaceholder()
                }
                
                else { //isLoading = true
                    ForEach((0..<5), id:\.self ) { _ in
                        cardView(for: .preview)
                            .redacted(reason: .placeholder)
                            .shimmering(active: listViewModel.isLoading)
                    }
                }
            }
            .introspectScrollView(customize: { scrollView in
                print("Introspect scroll view")
                scrollView.setContentOffset(listViewModel.scrollTracker.currentOffset, animated: true)
            })
            .introspectTableView(customize: { tableview in
                print("Introspect table view ")
                tableview.setContentOffset(listViewModel.scrollTracker.currentOffset, animated: true)
            })
            .modifier(
                ListDidScrollViewModifier(currentOffset: listViewModel.scrollTracker.currentOffset,
                                          didScroll: { offset in
                                              listViewModel.scrollTracker.trackContentOffset(offset)
                                          })
            )
            .listStyle(.plain)
            .transition(.move(edge: .top))
            .environmentObject(viewModel.viewState)
            .onAppear {
//                let headerBackground = UIView()
//                headerBackground.backgroundColor = .brand1
//
//                UITableViewHeaderFooterView.appearance().backgroundView = headerBackground
//                UITableView.appearance().sectionHeaderTopPadding = 0 //To remove the space between the info header view and the segmented view
    //            UITableView.appearance().estimatedRowHeight = 48
                            
                if !listViewModel.didEnd, !listViewModel.isLoading, listViewModel.feeds.isEmpty {
                    listViewModel.fetchFeeds(shouldRefresh: true)
                }
            }
            .refreshable {
                await listViewModel.asyncRefreshFeeds()
            }
            /*
             .onChange(of: scrollOffset, perform: { newValue in
                 let viewModel = segmentList.segments[segmentList.currentIndex]
                 viewModel.scrollTracker.trackContentOffset(newValue)
             })
             */
        }
        
    }
    
    
    @ViewBuilder private func addFeedView() -> some View {
        if (SGAppSession.shared.user.value?.role == .celebrity) {
            Button {
                self.createPost = true
            } label: {
                HStack(alignment: .center) {
                    Text("feed.home.create.title".localizedKey)
                        .foregroundColor(.text1)
                        .font(.system(size: 16,
                                      weight: .regular))
                    
                    Spacer()
                    
                    Image("eAdd")
                        .renderingMode(.template)
                        .tint(.text1)
                }
                .frame(height: 54)
                .padding(.horizontal, 20)
                .background(
                    Color.feedCreateBackground
                        .opacity(0.06)
                        .cornerRadius(10)
                    
                )
            }
            .buttonStyle(.borderless)
            .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.brand1)
        }
        else {
            EmptyView()
        }
    }
    
    private func cardView(for feed: SGFeedViewModel) -> some View {
        SGFeedCardView(feed: feed)
            .listRowBackground(Color.brand1)
            .listRowSeparatorTint(.tableSeparator)
            .listRowInsets(.init())
    }
    
    @ViewBuilder
    private func listFooterView(for listViewModel: FeedListViewModel) -> some View {
        if !listViewModel.didEnd, !listViewModel.feeds.isEmpty {
            HStack {
                Spacer()
                Text("Fetching More…")
                    .foregroundColor(.text1)
                    .font(.system(size: 12, weight: .regular))
                    .opacity(0.7)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .onAppear {
                        listViewModel.fetchFeeds(shouldRefresh: false)
                    }
                    .listRowBackground(Color.brand1)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                
                Spacer()
            }
        }
        else {
            EmptyView()
        }
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
    
    //MARK: -
    private func applyFilters(_ filters: [SGFilter]) {
        if filters.isEmpty {
//            let segments = FeedSegmentsViewModel(segments: [])
            self.viewModel.filteredFeeds = nil
            self.viewModel.filterList.pickedFilters = []
            return
        }
        let filterVM = self.viewModel.filterList
        let sorted1 = filterVM.pickedFilters.sorted(by: { $0.id < $1.id })
        let sorted2 = filters.sorted(by: { $0.id < $1.id })
        
        let isEqual = sorted1 == sorted2
        
        if !isEqual {
            filterVM.pickedFilters = sorted2
            
            let genericFeeds = FeedListViewModel(for: nil,
                                                 type: .allFeedsList,
                                                 category: .generic,
                                                 filters: sorted2)
            
//            let exclusiveFeeds = FeedListViewModel(for: nil,
//                                                   type: .allFeedsList,
//                                                   category: .exclusive,
//                                                   filters: sorted2)
//
//            let segments = FeedSegmentsViewModel(segments: [genericFeeds,
//                                                            exclusiveFeeds])
//
            self.viewModel.filteredFeeds = genericFeeds
        }
    }
    
    //MARK: -
    private func uploadStatusView() -> some View {
        HStack(spacing: 10) {
            Spacer()
            if uploadManager.state == .fileUpload
                || uploadManager.state == .postCreate {
                ProgressView()
                    .tint(.darkText)
                    .progressViewStyle(.circular)
            }

            Text(uploadManager.state.title)
                .foregroundColor(.darkText)
                .font(.system(size: 12,
                              weight: .semibold))
            
            Spacer()
            
            if uploadManager.state == .failed {
                Button {
                    uploadManager.retry()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
//                        .padding(8)
                        .tint(.darkText)
                }

            }
        }
        .padding(5)
        .background(Color.brand2)
        .transition(.move(edge: .top))
        .animation(.linear(duration: 0.25), value: uploadManager.hasRequest)
//        .onDisappear {
////            <#code#>
//        }
    }
}

struct FeedsListView_Previews: PreviewProvider {
    static var previews: some View {
        FeedsListView(viewModel: FeedsViewModel())
    }
}
