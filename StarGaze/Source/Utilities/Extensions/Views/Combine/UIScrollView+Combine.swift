//
//  UIScrollView+Combine.swift
//  StarGaze
//
//  Created by Suraj Shetty on 21/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Combine
import UIKit

//Ref:- https://gist.github.com/freddyh/8bea56a33d05fd36238fde13c939a0d7

public enum ScrollViewDelegateEvent {
    case didScroll(scrollView: UIScrollView)
    case didZoom(scrollView: UIScrollView)
    case willBeginDragging(scrollView: UIScrollView)
    case willEndDragging((scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>))
    case didEndDragging((scrollView: UIScrollView, willDecelerate: Bool))
    case willBeginDecelerating(scrollView: UIScrollView)
    case didEndDecelerating(scrollView: UIScrollView)
    case didEndScrollingAnimation(scrollView: UIScrollView)
    case willBeginZooming((scrollView: UIScrollView, zoomedView: UIView?))
    case didEndZooming((scrollView: UIScrollView, zoomedView: UIView?, scale: CGFloat))
    case didScrollToTop(scrollView: UIScrollView)
    case didChangeAdjustedContentInset(scrollView: UIScrollView)
}

public extension UIScrollView {
    func delegatePublisher(shouldScrollToTopSubject: CurrentValueSubject<Bool, Never>,
                           viewForZoomingSubject: CurrentValueSubject<UIView?, Never> = .init(nil)) -> DelegatePublisher {
        DelegatePublisher(scrollView: self,
                          shouldScrollToTopSubject: shouldScrollToTopSubject,
                          viewForZoomingSubject: viewForZoomingSubject)
    }
    
    struct DelegatePublisher: Publisher {
        public typealias Output = ScrollViewDelegateEvent
        public typealias Failure = Never
        
        var scrollView: UIScrollView
        var shouldScrollToTopSubject: CurrentValueSubject<Bool, Never>
        var viewForZoomingSubject: CurrentValueSubject<UIView?, Never>
        
        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = DelegateSubscription<S>(target: subscriber,
                                                       shouldScrollToTopSubject: shouldScrollToTopSubject,
                                                       viewForZoomingSubject: viewForZoomingSubject)
            subscriber.receive(subscription: subscription)
            scrollView.delegate = subscription
        }
    }
    
    final class DelegateSubscription<Target: Subscriber>: NSObject, UIScrollViewDelegate, Subscription where Target.Input == ScrollViewDelegateEvent {
        
        init(target: Target,
             shouldScrollToTopSubject: CurrentValueSubject<Bool, Never>,
             viewForZoomingSubject: CurrentValueSubject<UIView?, Never>) {
            self.target = target
            self.shouldScrollToTopSubject = shouldScrollToTopSubject
            self.viewForZoomingSubject = viewForZoomingSubject
        }
        
        public func request(_ demand: Subscribers.Demand) {}
        
        public func cancel() {
            target = nil
        }
        
        var target: Target?
        var shouldScrollToTopSubject: CurrentValueSubject<Bool, Never>
        var viewForZoomingSubject: CurrentValueSubject<UIView?, Never>
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            _ = target?.receive(.didScroll(scrollView: scrollView))
        }
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            _ = target?.receive(.didZoom(scrollView: scrollView))
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            _ = target?.receive(.willBeginDragging(scrollView: scrollView))
        }
        
        public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                              withVelocity velocity: CGPoint,
                                              targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            _ = target?.receive(.willEndDragging((scrollView, velocity, targetContentOffset)))
        }
        
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                             willDecelerate decelerate: Bool) {
            _ = target?.receive(.didEndDragging((scrollView, decelerate)))
        }
        
        public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            _ = target?.receive(.willBeginDecelerating(scrollView: scrollView))
        }
        
        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            _ = target?.receive(.didEndDecelerating(scrollView: scrollView))
        }
        
        public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            _ = target?.receive(.didEndScrollingAnimation(scrollView: scrollView))
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            viewForZoomingSubject.value
        }
        
        public func scrollViewWillBeginZooming(_ scrollView: UIScrollView,
                                               with view: UIView?) {
            _ = target?.receive(.willBeginZooming((scrollView, view)))
        }

        public func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                            with view: UIView?,
                                            atScale scale: CGFloat) {
            _ = target?.receive(.didEndZooming((scrollView, view, scale)))
        }
        
        public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            shouldScrollToTopSubject.value
        }

        public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
            _ = target?.receive(.didScrollToTop(scrollView: scrollView))
        }
        
        public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
            _ = target?.receive(.didChangeAdjustedContentInset(scrollView: scrollView))
        }
    }
}
