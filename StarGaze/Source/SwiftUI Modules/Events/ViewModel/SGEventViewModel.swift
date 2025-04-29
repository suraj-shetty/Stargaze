//
//  SGEventViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

final class SGEventViewModel: ObservableObject, Identifiable {
    private(set) var event: Event
    private var cancellables = Set<AnyCancellable>()

    @Published var error:SGAPIError?
    @Published var totalParticipants: Int
    
    var id:Int {
        get { event.id }
    }
    
    var title: String {
        get { event.title }
    }
        
    var mediaURL: URL? {
        get { URL(string: event.mediaPath) }
    }
    
    var mediaType: SGMediaType {
        get { event.mediaType.mediaType }
    }
    
    var dateText: String {
        get {
            event.startDate.toFormat("MMM d' at 'h:mm a")
        }
    }
    
    init(event:Event) {
        self.event = event
        self.totalParticipants = event.participatesCount
    }
}


extension SGEventViewModel: Hashable {
    static func == (lhs: SGEventViewModel, rhs: SGEventViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
