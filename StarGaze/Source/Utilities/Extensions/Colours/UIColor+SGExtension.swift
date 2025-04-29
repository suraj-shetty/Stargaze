//
//  UIColor+SGExtension.swift
//  StarGaze
//
//  Created by Suraj Shetty on 14/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    @nonobjc class var brand1: UIColor {
        return UIColor{ traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(rgb: 0x151A20)
            default: return UIColor(rgb: 0xFFFFFF)
            }
        }
    }
    
    @nonobjc class var brand2: UIColor {
        return UIColor{ traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(rgb: 0xFDB722)
            default: return UIColor(rgb: 0xFDB722)
            }
        }
    }
    
    @nonobjc class var segmentTextHighlight: UIColor {
        return UIColor{ traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(rgb: 0x39414B)
            default: return UIColor(rgb: 0x39414B)
            }
        }
    }
    
    @nonobjc class var text1: UIColor {
        return UIColor{ traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(rgb: 0xFFFFFF)
            default: return UIColor(rgb: 0x151A20)
            }
        }
    }
    
    @nonobjc class var placeholder: UIColor {
        return UIColor{ traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(rgb: 0xD8D8D8)
            default: return UIColor(rgb: 0xD8D8D8)
            }
        }
    }
    
    @nonobjc class var likeHighlight: UIColor {
        return .brand2
    }
    
    @nonobjc class var seeMore: UIColor {
        return UIColor{ traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(rgb: 0xFAD64F)
            default: return UIColor(rgb: 0xFAD64F)
            }
        }
    }
    
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

            if hexFormatted.hasPrefix("#") {
                hexFormatted = String(hexFormatted.dropFirst())
            }

            assert(hexFormatted.count == 6, "Invalid hex code used.")

            var rgbValue: UInt64 = 0
            Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: alpha)
    }
}

// MARK: - SwiftUI Colors
extension Color {
    static var shadow: Color {
        return color(light: .gray,
                     dark: .black)
    }
    
    static var slate: Color {
        return color(light: UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1),
                     dark: UIColor(red: 30/255, green: 38/255, blue: 49/255, alpha: 1))
    }
    
    static var slate1: Color {
        return color(light: UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1),
                     dark: UIColor(red: 46/255, green: 51/255, blue: 59/255, alpha: 1))
    }
    
    static var borderGray: Color {
        return Color(red: 151/255, green: 151/255, blue: 151/255, opacity: 1)
    }
    
    static var coinsRed: Color {
        return Color(red: 239/255, green: 85/255, blue: 87/255, opacity: 1)
    }
    
    static var coinsBlue: Color {
        return Color(red: 96/255, green: 179/255, blue: 246/255, opacity: 1)
    }
    
    static var coinsGreen: Color {
        return Color(red: 0/255, green: 214/255, blue: 150/255, opacity: 1)
    }
    
    static var coinsPurple: Color {
        return Color(UIColor(rgb: 0xB65AFF))
    }
    
    
    private static func color(light: UIColor, dark: UIColor) -> Color {
        return Color(UIColor.dynamicColor(light: light, dark: dark))
    }
        
    static var brand1: Color {
        return Color(UIColor.brand1)
    }

    static var brand2: Color {
        return Color(UIColor.brand2)
    }

    static var text1: Color {
        return Color(UIColor.text1)
    }
    
    static var text2: Color {
        return  color(light: UIColor(rgb: 0x39414B),
                      dark: UIColor(rgb: 0xFFFFFF))
    }
    
    static var tableSeparator: Color {
        return  color(light: .text1.withAlphaComponent(0.3),
                      dark: .text1.withAlphaComponent(0.06))
    }
    
    static var comment:Color {
        return color(light: UIColor(rgb: 0xA7A7A7), dark: UIColor(rgb: 0xA7A7A7))
    }
    
    static var commentFieldBorder:Color {
        return color(light: UIColor(rgb: 0x979797), dark: UIColor(rgb: 0x979797))
    }
    
    static var eventCardBackground:Color {
        return color(light: UIColor(rgb: 0xF5F6F6), dark: UIColor(rgb: 0x18232E))
    }
    
    static var darkText: Color {
        return Color(UIColor(rgb: 0x151A21))
    }
    
    static var celebBrand: Color {
        return Color(UIColor(rgb: 0xFDC858))
    }
    
    static var almostBlack:Color {
        return Color(UIColor(rgb: 0x0F1216))
    }
    
    static var maize1: Color {
        return Color(UIColor(rgb: 0xfad64f))
    }
    
    static var maize2: Color {
        return Color(UIColor(rgb: 0xFBD253))
    }
    
    static var lightMustard2: Color {
        return Color(UIColor(rgb: 0xfccd56))
    }
    
    static var menuGradientLead: Color {
        return color(light: .white.withAlphaComponent(0.18),
                     dark: UIColor(rgb: 0x151A21))
    }
    
    static var menuGradientTrail: Color {
        return color(light: UIColor(rgb: 0x1E2631).withAlphaComponent(0.18),
                     dark: UIColor(rgb: 0x1E2631))
    }
    
    static var profileInfoBackground: Color {
        return color(light: UIColor(rgb: 0xF5F6F6),
                     dark: UIColor(rgb: 0x21272F))
    }
    
    static var profileSeperator: Color {
        return color(light: .black,
                     dark: .white)
        .opacity(0.06)
    }
    
    static var profileMenuIcon: Color {
        return color(light: UIColor(rgb: 0xfdc858),
                     dark: .white)
    }
    
    static var feedCreateBackground: Color {
        return color(light: UIColor(rgb: 0x39414B),
                     dark: UIColor(rgb: 0xD8D8D8))
    }
    
    static var textFieldBorder: Color {
        return color(light: UIColor(rgb: 0x989898).withAlphaComponent(0.36),
                     dark: UIColor.white.withAlphaComponent(0.48))
    }
    
    static var textFieldTitle: Color {
        return Color(UIColor(rgb: 0xFDC858))
    }
    
    static var winnerBorder: Color {
        return color(light: UIColor(rgb: 0xEEEEEE),
                     dark: UIColor.white.withAlphaComponent(0.26))
    }
    
    static func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color(uiColor: UIColor(rgb: 0xfdc858))
        case 2: return Color(uiColor: UIColor(rgb: 0xef5557))
        case 3: return Color(uiColor: UIColor(rgb: 0x60b3f6))
        default: return .profileInfoBackground
        }
    }
    
    static var earningViewBackground: Color {
        return color(light: UIColor(rgb: 0xf5f6f6),
                     dark: UIColor(rgb: 0xd8d8d8).withAlphaComponent(0.07))
    }
    
    static var earningIconTint: Color {
        return color(light: UIColor(rgb: 0x6e7277),
                     dark: UIColor.white.withAlphaComponent(0.35))
    }
    
    
    static var gunMetal: Color {
        return Color(UIColor(rgb: 0x595A5A))
    }
    
    static var charcoalGrey: Color {
        return Color(UIColor(rgb: 0x39414B))
    }
    
    static var tabItemColor: Color {
        return color(light: UIColor(Color.charcoalGrey),
                     dark: UIColor(Color.gunMetal))
    }
    
    static var mediaPlaceholder: Color {
        return color(light: UIColor(rgb: 0xf7f7f7),
                     dark: UIColor(rgb: 0x272e37))
        
    }
    
    static var mediaTextPlaceholder: Color {
        return color(light: UIColor.black,
                     dark: UIColor.white)
        
    }
    
    static var earnCoinsDesc: Color {
            return color(light: UIColor(rgb: 0x151a21),
                         dark: UIColor(rgb: 0x989898))
    }
    
    static var earnCoinsCellBackground: Color {
        return color(light: UIColor(rgb: 0xF1F1F1),
                     dark: UIColor(rgb: 0x21272F))
    }
    
    static var packageBackground: Color {
        return color(light: .white,
                     dark: UIColor(rgb: 0x21272F))
    }
    
    
    static var greyishBrown: Color {
        return Color(uiColor: UIColor(rgb: 0x545454))
    }
    
    static var coralPink: Color {
        return Color(uiColor: UIColor(rgb: 0xff5659))
    }
    
    static var fadedRed: Color {
        return Color(uiColor: UIColor(rgb: 0xd23e40))
    }
    
    static var watermelon: Color {
        return Color(uiColor: UIColor(rgb: 0xef5557))
    }
    
    static var brightCyan: Color {
        return Color(uiColor: UIColor(rgb: 0x46d9fb))
    }
    
    static var clearBlue: Color {
        return Color(uiColor: UIColor(rgb: 0x2f8df4))
    }
    
    static var softBlue: Color {
        return Color(uiColor: UIColor(rgb: 0x60b3f6))
    }
    
    static var liliac: Color {
        return Color(uiColor: UIColor(rgb: 0xbd95fc))
    }
    
    static var lightPurple: Color {
        return Color(uiColor: UIColor(rgb: 0xa674f7))
    }
    
    static var lightPurple2: Color {
        return Color(uiColor: UIColor(rgb: 0xa877f7))
    }
    
    static var brownGrey: Color {
        return Color(uiColor: UIColor(rgb: 0x7c7c7c))
    }
    
    static var gold: Color {
        return Color(UIColor(rgb: 0xFDC858))
    }
    
    static var silver: Color {
        return Color(UIColor(rgb: 0xebebeb))
    }
    
    static var greenBlue: Color {
        return Color(UIColor(rgb: 0x00d696))
    }
    
    static var veryLightPink: Color {
        return Color(uiColor: .init(rgb: 0xdbdbdb))
    }
    
    static var packageCellBackground: Color {
        return color(light: UIColor(rgb: 0xf6f6f6).withAlphaComponent(0.7),
                     dark: UIColor(rgb: 0x151a21).withAlphaComponent(0.7))
    }
    
    static var packageLinkText: Color {
        return color(light: UIColor(rgb: 0x151a21),
                     dark: .white.withAlphaComponent(0.59))
    }
    
    static var packageHighlight: Color {
        return color(light: UIColor(rgb: 0xfdb722),
                     dark: UIColor(rgb: 0xfdc858))
    }
    
    static var lowCoinBalanceText: Color {
        //
        return color(light: UIColor(rgb: 0xff3b30),
                     dark: .white)
    }
    
    static var walletTileBackground: Color {
        return color(light: UIColor(rgb: 0xF7F7F7),
                     dark: UIColor(rgb: 0x21272F))
    }
    
    static var walletBalanceTitle: Color {
        return color(light: UIColor(rgb: 0x151a21),
                     dark: .white)
    }
    
    static var walletContentBackground: Color {
        return color(light: UIColor(rgb: 0xf7f7f7),
                     dark: UIColor(rgb: 0x1a2028))
    }
}

extension Color {
    static var toolBackground: Color {
        return Color(UIColor(white: 33.0/255.0, alpha: 1))
    }
    
    static var controlBackground: Color {
        return Color(UIColor(white: 28.0/255.0, alpha: 1))
    }
    
    static var editorBackground: Color {
        return Color(UIColor(white: 28.0/255.0, alpha: 1))
    }

    static var iconBackground: Color {
        return Color(UIColor(white: 64.0/255.0, alpha: 1))
    }
    
    static var iconBorder: Color {
        return Color(UIColor(white: 107.0/255.0, alpha: 1))
    }
    
}
