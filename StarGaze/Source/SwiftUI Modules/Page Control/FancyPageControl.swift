//
//  FancyPageControl.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 04/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

//Source: - https://betterprogramming.pub/custom-paging-ui-in-swiftui-13f1347cf529

struct FancyPageControl: View {
  
  // MARK: - Public Properties
  
  let numberOfPages: Int
  let currentIndex: Int
  
  
  // MARK: - Drawing Constants
  
  private let circleSize: CGFloat = 12
  private let circleSpacing: CGFloat = 12
  
  private let primaryColor = Color.white
  private let secondaryColor = Color.white.opacity(0.6)
  
  private let smallScale: CGFloat = 0.6
  
  
  // MARK: - Body
  
  var body: some View {
    HStack(spacing: circleSpacing) {
        ForEach(0..<numberOfPages, id: \.self) { index in // 1
        if shouldShowIndex(index) {
          Circle()
            .fill(currentIndex == index ? primaryColor : secondaryColor) // 2
            .scaleEffect(currentIndex == index ? 1 : smallScale)
            
            .frame(width: circleSize, height: circleSize)
       
            .transition(AnyTransition.opacity.combined(with: .scale)) // 3
            
            .id(index) // 4
        }
      }
    }
  }
  
  
  // MARK: - Private Methods
  
  func shouldShowIndex(_ index: Int) -> Bool {
    ((currentIndex - 2)...(currentIndex + 2)).contains(index)
  }
}
