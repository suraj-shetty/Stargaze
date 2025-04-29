//
//  Font.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

//Ref:- https://gist.github.com/sauvikatinnofied/3aad89cbaf1ea908e9b6c7f0e5829c49

struct SGFont {

    enum FontType {
        case installed(FontName)
        case custom(String)
        case system
        case systemBold
        case systemItatic
        case systemWeighted(weight: UIFont.Weight)
        case monoSpacedDigit(size: Double, weight: UIFont.Weight)
    }
    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        var value: Double {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }
    enum FontName: String {
        case GTWalsheimProRegular    = "GTWalsheimProRegular"
        case GTWalsheimProMedium    = "GTWalsheimPro-Medium"
        case BrandonBlack           = "BrandonGrotesque-Black"
        case LouisianaRegular       = "LouisianaW00-Regular"
        
    }
    
    enum StandardSize: Double {
        case h1 = 20.0
        case h2 = 18.0
        case h3 = 16.0
        case h4 = 14.0
        case h5 = 12.0
        case h6 = 10.0
    }

    
    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension SGFont {
    
    var instance: UIFont {
        
        var instanceFont: UIFont!
        switch type {
        case .custom(let fontName):
            guard let font =  UIFont(name: fontName, size: CGFloat(size.value)) else {
                fatalError("\(fontName) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .installed(let fontName):
            guard let font =  UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                fatalError("\(fontName.rawValue) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .system:
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value))
        case .systemBold:
            instanceFont = UIFont.boldSystemFont(ofSize: CGFloat(size.value))
        case .systemItatic:
            instanceFont = UIFont.italicSystemFont(ofSize: CGFloat(size.value))
        case .systemWeighted(let weight):
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value),
                                             weight: weight)
        case .monoSpacedDigit(let size, let weight):
            instanceFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size),
                                                            weight: weight)
        }
        return instanceFont
    }
}

class Utility {
    /// Logs all available fonts from iOS SDK and installed custom font
    class func logAllAvailableFonts() {
        for family in UIFont.familyNames {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}

// MARK: - SWIFTUI Fonts
extension Font {
    static func brandonBlk(size: CGFloat) -> Font {
        return Font.custom(SGFont.FontName.BrandonBlack.rawValue, size: size)
    }
    
    static func louisianaRegular(size: CGFloat) -> Font {
        return Font.custom(SGFont.FontName.LouisianaRegular.rawValue, size: size)
    }
    
    static func walsheimRegular(size: CGFloat) -> Font {
        return Font.custom(SGFont.FontName.GTWalsheimProRegular.rawValue, size: size)
    }
    
    static func walsheimMedium(size: CGFloat) -> Font {
        return Font.custom(SGFont.FontName.GTWalsheimProMedium.rawValue, size: size)
    }
}
