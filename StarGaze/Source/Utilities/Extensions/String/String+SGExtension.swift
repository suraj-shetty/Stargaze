//
//  String+SGExtension.swift
//  StarGaze
//
//  Created by Suraj Shetty on 03/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI
import KMBFormatter

extension String {
    var localizedKey:LocalizedStringKey {
        return LocalizedStringKey(self)
    }
    
    func formattedString(value:Int) -> String {
        let formattedValue = KMBFormatter.shared.string(fromNumber: Int64(value))
        
        let formatText = NSLocalizedString(self, comment: "")
        let text = String.localizedStringWithFormat(formatText, formattedValue, value)
        return text
    }
}
