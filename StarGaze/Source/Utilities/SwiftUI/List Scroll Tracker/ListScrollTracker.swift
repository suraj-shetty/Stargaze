//
//  ListScrollTracker.swift
//  StarGaze
//
//  Created by Suraj Shetty on 31/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum ListScrollDirection {
    case horizontal
    case vertical
}

final class ListScrollTracker {
    private var elementFrameRecord = [Int: CGRect]()
    private var visibleElementRecord = [Int: Bool]()
    private var viewSize: CGSize = .zero
    private var direction: ListScrollDirection = .vertical
    
    private var offsetRecord: (first: CGFloat?, current:CGFloat?) = (nil, nil)
    private let offsetSubject = PassthroughSubject<CGFloat, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var currentOffset: CGPoint = .zero
    let centeredElementPublisher = PassthroughSubject<Int, Never>()
    
    init(direction:ListScrollDirection = .vertical) {
        self.direction = direction
        
        offsetSubject
            .dropFirst()
            .throttle(for: .seconds(0.15),
                      scheduler: DispatchQueue.main,
                      latest: true)
            .sink { [weak self] in
                self?.offsetRecord.current = $0
                if self?.offsetRecord.first == nil {
                    self?.offsetRecord.first = $0
                }
                self?.identifyMostVisibleElement()
            }
            .store(in: &cancellables)
    }
    
    func trackFrame(_ frame:CGRect, for position:Int, inViewSize size:CGSize) {
        elementFrameRecord[position] = frame
        viewSize = size
    }
    
    func trackAppeared(at position:Int) {
        visibleElementRecord[position] = true
        identifyMostVisibleElement()
    }
    
    func trackDisappeared(at position:Int) { //Since the item/row is not visible, remove any reference of it
        visibleElementRecord[position] = nil
        elementFrameRecord[position] = nil
    }
    
    func trackContentOffset(_ offset: CGPoint) {
        self.currentOffset = offset
        offsetSubject.send(direction == .vertical ? offset.y : offset.x)
    }
    
    func identifyMostVisibleElement() {
//        guard case var (.some(firstOffset), .some(currentOffset)) = offsetRecord else {
//            // Don't calculate if we have not recorded any offset changes
//            return
//        }
//        
//        firstOffset = max(firstOffset, CGFloat.zero) // Ignore negative offset
//        currentOffset = max(currentOffset, CGFloat.zero) // Ignore negative offset
        
//        guard abs(currentOffset - firstOffset) > CGFloat(16) else {
//            // Don't update when the scroll offset change is neglectable
//            return
//        }
        
        let viewCenter = ((direction == .vertical) ? viewSize.height : viewSize.width) / CGFloat(2)
        var centeredElement: Int?
        var shortestDistance: CGFloat = 0
        
        for elementKey in visibleElementRecord.keys {
            guard let frame = elementFrameRecord[elementKey]
            else { continue }
            
            let elementCenter = (direction == .vertical) ? frame.midY : frame.midX
            
            if centeredElement == nil {
                centeredElement = elementKey
                shortestDistance = abs(viewCenter - elementCenter)
                continue
            }
            
            let distance = abs(viewCenter - elementCenter)
            if distance < shortestDistance {
                shortestDistance = distance
                centeredElement = elementKey
            }
        }
        
        if centeredElement != nil { //If element found
            centeredElementPublisher.send(centeredElement!)
//            self.visibleElement = centeredElement
        }
    }
}
