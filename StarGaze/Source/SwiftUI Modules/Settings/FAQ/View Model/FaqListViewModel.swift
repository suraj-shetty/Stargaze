//
//  FaqListViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 31/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

class FaqListViewModel: ObservableObject {
    @Published var items:[FaqViewModel] = []
    
    init() {
        let items = [
            FaqViewModel(title: NSLocalizedString("faq.star-account.question", comment: ""),
                         info: NSLocalizedString("faq.star-account.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.account.logout.question", comment: ""),
                         info: NSLocalizedString("faq.account.logout.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.event.create.question", comment: ""),
                         info: NSLocalizedString("faq.event.create.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.event.promote.question", comment: ""),
                         info: NSLocalizedString("faq.event.promote.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.post-updates.question", comment: ""),
                         info: NSLocalizedString("faq.post-updates.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.event-detail.see.question", comment: ""),
                         info: NSLocalizedString("faq.event-detail.see.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.report-caller.question", comment: ""),
                         info: NSLocalizedString("faq.report-caller.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.earning.see.question", comment: ""),
                         info: NSLocalizedString("faq.earning.see.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.notification.question", comment: ""),
                         info: NSLocalizedString("faq.notification.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.disallow-followers.question", comment: ""),
                         info: NSLocalizedString("faq.disallow-followers.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.follow-star.question", comment: ""),
                         info: NSLocalizedString("faq.follow-star.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.join-event.question", comment: ""),
                         info: NSLocalizedString("faq.join-event.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.event-cost.question", comment: ""),
                         info: NSLocalizedString("faq.event-cost.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.celeb-call.question", comment: ""),
                         info: NSLocalizedString("faq.celeb-call.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.ensure-event-win.question", comment: ""),
                         info: NSLocalizedString("faq.ensure-event-win.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.free-coins.earn.question", comment: ""),
                         info: NSLocalizedString("faq.free-coins.earn.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.purchased-coins.claim.question", comment: ""),
                         info: NSLocalizedString("faq.purchased-coins.claim.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.premium-account.question", comment: ""),
                         info: NSLocalizedString("faq.premium-account.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.premium-account.benefits.question", comment: ""),
                         info: NSLocalizedString("faq.premium-account.benefits.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.event-won.notification.question", comment: ""),
                         info: NSLocalizedString("faq.event-won.notification.answer", comment: "")),
            
            FaqViewModel(title: NSLocalizedString("faq.celeb-content.react.question", comment: ""),
                         info: NSLocalizedString("faq.celeb-content.react.answer", comment: ""))
        ]
        
        self.items = items
    }
}
