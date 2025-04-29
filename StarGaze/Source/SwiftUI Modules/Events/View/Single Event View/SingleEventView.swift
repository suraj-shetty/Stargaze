//
//  SingleEventView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 16/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct SingleEventView: View {
    @StateObject var viewModel: SingleEventViewModel
    var onClose:(()->())
    
    var body: some View {
        ZStack {
            EventSlideDataView(event: $viewModel.event)
                .environmentObject(viewModel.viewState)
            
            VStack {
                Spacer()
                Text("Swipe up for more..".uppercased())
                    .font(.walsheimRegular(size: 12))
                    .foregroundColor(.text1)
                    .padding(.bottom, 26)
                    .padding(.top, 30)
            }
            
            VStack {
                HStack {
                    Button {
                        onClose()
                    } label: {
                        Image("navClose")
                            .tint(.text1)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 44, height: 44)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            BottomSheetView(event: $viewModel.event,
                            isOpen: $viewModel.isSliderOpen) {
                // Bid to win action
                withAnimation(.spring()) {
                    viewModel.bidOffSet = -UIScreen.main.bounds.height
                }
            }
            .background(viewModel.isSliderOpen
                        ? Color.brand1.opacity(0.3)
                        : Color.clear)
            
            EventBidView(endOffsetY: $viewModel.bidOffSet,
                         action: {
//                viewModel.bidEvent()
            },
                         coinNumber: $viewModel.bidCoins,
                         totalCoins: $viewModel.totalCoins)
            .background(viewModel.bidOffSet == 0
                        ? Color.clear
                        : Color.text1.opacity(0.5))
            
        }
        .background {
            Color.brand1
        }
        .onAppear {
            viewModel.viewState.isVisible = true
        }
        .onDisappear(perform: {
            viewModel.viewState.isVisible = false
        })
        .onChange(of: viewModel.isSliderOpen) { newValue in
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
    }
}

struct SingleEventView_Previews: PreviewProvider {
    static var previews: some View {
        SingleEventView(viewModel: SingleEventViewModel(event: .mockEvents.first!)) {
            
        }
    }
}
