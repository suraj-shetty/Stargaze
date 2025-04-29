//
//  ListDidScrollViewModifier.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Introspect

struct ListDidScrollViewModifier: ViewModifier {
    class ViewModel: ObservableObject {
        @Published var contentOffset: CGPoint = .zero
        
        var contentOffsetSubscription: AnyCancellable?
        
        func subscribe(scrollView: UIScrollView) {
            contentOffsetSubscription = scrollView.publisher(for: \.contentOffset)
                .removeDuplicates()
                .sink { [weak self] contentOffset in
                    self?.contentOffset = contentOffset
                }
        }
    }
    
    @StateObject var viewModel = ViewModel()
    var currentOffset: CGPoint = .zero
    var didScroll: (CGPoint) -> Void
    
    func body(content: Content) -> some View {
        content
        
            .introspectTableView { scrollView in
                if viewModel.contentOffsetSubscription == nil {
                    viewModel.subscribe(scrollView: scrollView)
                }
                
//                print("List Scroll introspectTableView")
//                print("Offset \(viewModel.contentOffset)")
                
            }
            .onReceive(viewModel.$contentOffset) { contentOffset in
                didScroll(contentOffset)
            }
            .onAppear(perform: {
//                print("List Scroll modifier didAppear")
//                print("Offset \(currentOffset)")
                viewModel.contentOffset = currentOffset
            })
    }
}

extension View {
    func didScroll(_ didScroll: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(ListDidScrollViewModifier(didScroll: didScroll))
    }
}
