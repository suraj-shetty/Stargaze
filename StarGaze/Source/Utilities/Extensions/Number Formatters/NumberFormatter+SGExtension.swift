//
//  NumberFormatter+SGExtension.swift
//  StarGaze
//
//  Created by Suraj Shetty on 29/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

extension NumberFormatter {
    
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter
    }()
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter
    }()
}

extension Int {
    func localeFormatted() -> String {
        return NumberFormatter.decimalFormatter
            .string(from: NSNumber(integerLiteral: self)) ?? ""
    }
}
