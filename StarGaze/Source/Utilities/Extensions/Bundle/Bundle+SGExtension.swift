//
//  Bundle+SGExtension.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "Version \(releaseVersionNumber ?? "1.0.0")"
    }
}
