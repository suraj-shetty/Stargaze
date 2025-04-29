//
//  KeyboardManager.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import UIKit

class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isVisible = false
    
    var keyboardCancellable = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                
                guard let userInfo = notification.userInfo else { return }
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                debugPrint("Keyboard frame \(keyboardFrame)")
                
                self.isVisible = true
                self.keyboardHeight = keyboardFrame.height
            }
            .store(in: &keyboardCancellable)
        
        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillHideNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                
//                guard let userInfo = notification.userInfo else { return }
//                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
//                debugPrint("Keyboard frame \(keyboardFrame)")
                
                self.isVisible = false
                self.keyboardHeight = 0
            }
            .store(in: &keyboardCancellable)
        
        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                
                guard let userInfo = notification.userInfo else { return }
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                debugPrint("Keyboard frame \(keyboardFrame)")
                
//                self.isVisible = keyboardFrame.minY < UIScreen.main.bounds.height
                self.keyboardHeight = keyboardFrame.height
            }
            .store(in: &keyboardCancellable)
    }
    
    deinit {
        keyboardCancellable.forEach({ $0.cancel() })
    }
    
}
