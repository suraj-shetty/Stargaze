//
//  Date+SGExtension.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 28/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

extension Date {
    var countDown: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]

        return formatter.string(from: Date(), to: self) ?? "Error!"
    }
    
    var serverString: String {
        let serverFormatter = DateFormatter()
        serverFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return serverFormatter.string(from: self)
    }
}
