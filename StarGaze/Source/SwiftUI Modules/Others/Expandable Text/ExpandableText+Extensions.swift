//
//  Extension.swift
//  ExpandableText
//
//  Created by Suraj Shetty on 20/08/22.
//

import SwiftUI

extension ExpandableText {
    public func font(_ font: Font) -> ExpandableText {
        var result = self
        result.font = font
        return result
    }
    public func lineLimit(_ lineLimit: Int) -> ExpandableText {
        var result = self
        result.lineLimit = lineLimit
        return result
    }
    
    public func foregroundColor(_ color: Color) -> ExpandableText {
        var result = self
        result.foregroundColor = color
        return result
    }
    
    public func highlightColor(_ color: Color) -> ExpandableText {
        var result = self
        result.highlightColor = color
        return result
    }
    
    public func expandButton(_ expandButton: TextSet) -> ExpandableText {
        var result = self
        result.expandButton = expandButton
        return result
    }
    
//    public func collapseButton(_ collapseButton: TextSet) -> ExpandableText {
//        var result = self
//
//        result.collapseButton = collapseButton
//        return result
//    }
    
    public func expandAnimation(_ animation: Animation?) -> ExpandableText {
        var result = self
        
        result.animation = animation
        return result
    }
    
    public func lineSpacing(_ spacing: CGFloat) -> ExpandableText {
        var result = self
        result.lineSpacing = spacing
        return result
    }
}

extension String {
    func height(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func width(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

extension Font {
    func toUIFont() -> UIFont {
        if #available(iOS 14.0, *) {
            switch self {
            case .largeTitle:
                return UIFont.preferredFont(forTextStyle: .largeTitle)
            case .title:
                return UIFont.preferredFont(forTextStyle: .title1)
            case .title2:
                return UIFont.preferredFont(forTextStyle: .title2)
            case .title3:
                return UIFont.preferredFont(forTextStyle: .title3)
            case .headline:
                return UIFont.preferredFont(forTextStyle: .headline)
            case .subheadline:
                return UIFont.preferredFont(forTextStyle: .subheadline)
            case .callout:
                return UIFont.preferredFont(forTextStyle: .callout)
            case .caption:
                return UIFont.preferredFont(forTextStyle: .caption1)
            case .caption2:
                return UIFont.preferredFont(forTextStyle: .caption2)
            case .footnote:
                return UIFont.preferredFont(forTextStyle: .footnote)
            case .body:
                return UIFont.preferredFont(forTextStyle: .body)
            default:
                return UIFont.preferredFont(forTextStyle: .body)
            }
        } else {
            switch self {
            case .largeTitle:
                return UIFont.preferredFont(forTextStyle: .largeTitle)
            case .title:
                return UIFont.preferredFont(forTextStyle: .title1)
                //            case .title2:
                //                return UIFont.preferredFont(forTextStyle: .title2)
                //            case .title3:
                //                return UIFont.preferredFont(forTextStyle: .title3)
            case .headline:
                return UIFont.preferredFont(forTextStyle: .headline)
            case .subheadline:
                return UIFont.preferredFont(forTextStyle: .subheadline)
            case .callout:
                return UIFont.preferredFont(forTextStyle: .callout)
            case .caption:
                return UIFont.preferredFont(forTextStyle: .caption1)
                //            case .caption2:
                //                return UIFont.preferredFont(forTextStyle: .caption2)
            case .footnote:
                return UIFont.preferredFont(forTextStyle: .footnote)
            case .body:
                return UIFont.preferredFont(forTextStyle: .body)
            default:
                return UIFont.preferredFont(forTextStyle: .body)
            }
        }
    }
}

public struct TextSet {
    let text: String
    let font: Font
    let color: Color
}
