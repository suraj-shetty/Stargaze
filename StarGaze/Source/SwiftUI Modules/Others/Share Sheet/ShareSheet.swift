//
//  ShareSheet.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 09/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    var callback: Callback? = nil
    
    init(activityItems: [Any], callback: Callback?) {
        self.activityItems = activityItems
        self.callback = callback
                
        var excludedTypes: [UIActivity.ActivityType] = [.addToReadingList,
                                                        .airDrop,
                                                        .assignToContact,
                                                        .copyToPasteboard,
                                                        .markupAsPDF,
                                                        .openInIBooks,
                                                        .print,
                                                        .saveToCameraRoll]
        if #available(iOS 15.4, *) {
            excludedTypes.append(.sharePlay)
        }
        if #available(iOS 16.0, *) {
            excludedTypes.append(contentsOf: [.collaborationCopyLink,
                .collaborationInviteWithLink])
        }
        
        self.excludedActivityTypes = excludedTypes
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}

extension URL: Identifiable {
    public var id: String {
        return self.absoluteString
    }
    
    
}
