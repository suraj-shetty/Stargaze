//
//  PackageViewModel.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 21/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

struct PackageViewModel: Identifiable, Equatable {
    let id: Int
    let duration: Int
    let cost: Int
    let isRecommended: Bool
}
