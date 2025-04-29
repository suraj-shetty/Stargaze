//
//  StoreConstants.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import SwiftUI

enum StoreCoinOptions: String, CaseIterable {
//    case coin100 = "com.day1tech.stargaze.coins.option1"
    
    case coin100 = "com.stargazeqa.coinpurchase.option1"
    case coin500 = "com.stargazeqa.coinpurchase.option2"
    case coin1000 = "com.stargazeqa.coinpurchase.option3"
    case coin2500 = "com.stargazeqa.coinpurchase.option4"
    case coin5000 = "com.stargazeqa.coinpurchase.option5"
}

extension StoreCoinOptions {
    var tileColor: Color {
        get {
            switch self {
            case .coin100:
                return .brand2
            case .coin500:
                return .coinsRed
            case .coin1000:
                return .coinsBlue
            case .coin2500:
                return .coinsGreen
            case .coin5000:
                return .coinsPurple
            }
        }
    }
    
    var coins: Int {
        get {
            switch self {
            case .coin100:
                return 100
            case .coin500:
                return 500
            case .coin1000:
                return 1000
            case .coin2500:
                return 2500
            case .coin5000:
                return 5000
            }
        }
    }
    
    var appstoreID: String {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        switch self {
        case .coin100:
            return bundleID.appending(".coinpurchase.option1")
        case .coin500:
            return bundleID.appending(".coinpurchase.option2")
        case .coin1000:
            return bundleID.appending(".coinpurchase.option3")
        case .coin2500:
            return bundleID.appending(".coinpurchase.option4")
        case .coin5000:
            return bundleID.appending(".coinpurchase.option5")
        }
    }        
}

