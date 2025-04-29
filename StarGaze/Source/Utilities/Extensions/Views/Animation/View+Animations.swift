//
//  View+Animations.swift
//  StarGaze
//
//  Created by Suraj Shetty on 01/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
