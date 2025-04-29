//
//  ViewState.swift
//  StarGaze
//
//  Created by Suraj Shetty on 12/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

/*
 During development, we observed that certain UI elements (SGFeedCardView, PlayerView etc) were visible, even when another UI was presented modally.
 Also TabView was loading multiple views thereby calling onAppear, even when there were not visible
 This class's object is used by chil views, to check whether the parent was still visible.
 This class's object should be passed as EnvironmentObject
 */
class ViewState: NSObject, ObservableObject {
    @Published var isVisible: Bool = false
}
