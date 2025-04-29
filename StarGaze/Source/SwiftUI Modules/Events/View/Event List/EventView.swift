//
//  EventView.swift
//  StarGaze_Test
//
//  Created by Sourabh Kumar on 27/04/22.
//

import SwiftUI

struct EventView: View {
    @ObservedObject var viewModel: EventListViewModel
    @State var isSliderOpen: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if !viewModel.events.isEmpty {
                    TabView(selection: $viewModel.selectedIndex) {
                        ForEach($viewModel.events, id:\.id) { event in
                            EventSlideDataView(event: event)
                                .tag(viewModel.tag(for: event.wrappedValue))
                                .environmentObject(viewModel.viewState)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                if viewModel.events.isEmpty && viewModel.eventsFetched {
                    NoEventView()
                } else {
                    VStack {
                        Spacer()
                        HStack {
                            if viewModel.isPreviousEnabled {
                                Button {
                                    // Previous Event Action
                                    viewModel.previousAction()
                                } label: {
                                    PreviousEventView(image: viewModel.previousImage)
                                }
                            }
                            
                            Spacer()
                            
                            if viewModel.isNextEnabled {
                                Button {
                                    // Next Event Action
                                    viewModel.nextAction()
                                } label: {
                                    NextEventView(image: viewModel.nextImage)
                                }
                            }
                        }
                        .padding(.bottom, 70)
                        
                        Text("Swipe up for more..".uppercased())
                            .font(.walsheimRegular(size: 12))
                            .foregroundColor(.text1)
                            .padding(.bottom, 26)
                            .padding(.top, 30)
                    }
                    
                }
                
                VStack {
                    SearchAndSortView(viewModel: viewModel)
                    Spacer()
                }
                
                if viewModel.events.count > 0 {
                    let color = isSliderOpen ? Color.brand1.opacity(0.3) : Color.clear
                    BottomSheetView(event: $viewModel.events[viewModel.selectedIndex], isOpen: $isSliderOpen) {
                        // Bid to win action
                        withAnimation(.spring()) {
                            viewModel.bidOffSet = -UIScreen.main.bounds.height
                        }
                    }
                    .background(color)
                }
                
                
                let color: Color = viewModel.bidOffSet == 0 ? Color.clear : Color.text1.opacity(0.5)
                EventBidView(endOffsetY: $viewModel.bidOffSet, action: {
                    viewModel.bidEvent()
                }, coinNumber: $viewModel.bidCoins, totalCoins: $viewModel.totalCoins)
                .background(color)
                
                VStack {
                    if let singleEventVM = viewModel.eventViewModel {
                        SingleEventView(viewModel: singleEventVM) {
                            if let event = viewModel.eventViewModel?.event {
                                viewModel.didExitFrom(event: event)
                            }

                            withAnimation {
                                viewModel.eventViewModel = nil
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
                }                
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.brand1)
            .navigationBarHidden(true)
//            .animation(Animation.linear, value: viewModel.eventViewModel)
        }
        .onAppear {
            if viewModel.eventViewModel == nil {
                viewModel.viewState.isVisible = true
            }
            viewModel.getEvents()
        }
        .onDisappear(perform: {
            viewModel.viewState.isVisible = false
        })
        .onChange(of: isSliderOpen) { newValue in
            viewModel.viewState.isVisible = !newValue
        }
        .onReceive(NotificationCenter.default
            .publisher(for: .menuWillShow)
        ) { _ in
            viewModel.viewState.isVisible = false
        }
        .onReceive(NotificationCenter.default
            .publisher(for: .menuDidHide)
        ) { _ in
            viewModel.viewState.isVisible = true
        }
        .onChange(of: viewModel.eventViewModel) { newValue in
            viewModel.viewState.isVisible = (newValue == nil)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(viewModel: EventListViewModel())
    }
}

struct SearchAndSortView: View {
    @ObservedObject var viewModel: EventListViewModel
    @StateObject var filterListVM = FilterListViewModel()
    
    @State private var loadSearch: Bool = false
    @State var showFilter: Bool = false

    var body: some View {
        navView()
            .padding(.horizontal, 10)
        .fullScreenCover(isPresented: $loadSearch,
                         content: {
            SearchView()
        })
        .fullScreenCover(isPresented: $showFilter, content: {
            FilterListView(viewModel: filterListVM,
                           onFilterChanged: { picked in
                filterListVM.pickedFilters = picked
                viewModel.applyFilters(filters: picked)
            })
            .edgesIgnoringSafeArea(.vertical)
        })
        .onAppear {
            if filterListVM.datasource.isEmpty {
                filterListVM.fetchFilters()
            }
        }
        .onChange(of: loadSearch) { newValue in
            viewModel.viewState.isVisible = !newValue
        }
        .onChange(of: showFilter) { newValue in
            viewModel.viewState.isVisible = !newValue
        }
    }
    
    @ViewBuilder
    private func navView() -> some View {
        if viewModel.isCelebrityMode {
            celebNavView()
        }
        else {
            userNavView()
        }
    }
    
    private func userNavView() -> some View {
        HStack {
            Button {
                loadSearch = true
            } label: {
                Image("searchEvent", bundle: nil)
                    .tint(Color.text1)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            Button {
                self.showFilter = true
            } label: {
                Image("sortTool", bundle: nil)
                    .tint(filterListVM.pickedFilters.isEmpty ? .text1 : .brand2)
            }
            .frame(width: 44, height: 44)
        }
    }
    
    private func celebNavView() -> some View {
        HStack(spacing:0) {
            Button {
                viewModel.addEvent()
            } label: {
                Image("eventAdd", bundle: nil)
                    .tint(Color.text1)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            NavigationLink("", isActive: $viewModel.eventAddInitiate) {
                AddEventView(viewModel: AddEventViewModel(.videoCall))
            }
            
            Button {
                self.showFilter = true
            } label: {
                Image("sortTool", bundle: nil)
                    .tint(filterListVM.pickedFilters.isEmpty ? .text1 : .brand2)
            }
            .frame(width: 44, height: 44)
            
            Button {
                loadSearch = true
            } label: {
                Image("searchEvent", bundle: nil)
                    .tint(Color.text1)
            }
            .frame(width: 44, height: 44)
        }
    }
}

