//
//  Styling.swift
//
//
//  Created by Bernd Rabe on 10.06.15.
//  Copyright (c) 2015 RABE_IT Services. All rights reserved.
//

import Foundation
import UIKit

enum FontDesc: String, CustomStringConvertible {
    case NeueLight    = "HelveticaNeue-Light"
    case NeueMedium   = "HelveticaNeue-Medium"
    case NeueBold     = "HelveticaNeue-Bold"
    case NeueRegular  = "HelveticaNeue"
    case Regular      = "Helvetica"
    case Light        = "Helvetica-Light"
    case Oblique      = "Helvetica-Oblique"
    case LightOblique = "Helvetica-LightOblique"
    
    var fontWeight: CGFloat {
        switch self {
        case .Light, .NeueLight:         return UIFontWeightLight
        case .Regular, .NeueRegular:     return UIFontWeightRegular
        case .NeueBold, .Oblique:        return UIFontWeightBold
        case .NeueMedium, .LightOblique: return UIFontWeightMedium
        }
    }
    
    var description: String {
        return "FontDesc: fontName: \(fontName)"
    }
    
    var fontName: String {
        return self.rawValue
    }
}

enum SizeDesc: CGFloat, CustomStringConvertible {
    case Tiny    = 10.0
    case Small   = 12.0
    case Compact = 14.0
    case Medium  = 16.0
    case Big     = 20.0
    case XXL     = 40.0
    
    var fontSize: CGFloat {
        return self.rawValue
    }

    var description: String {
        return "ColorDesc: \(self.rawValue)pt"
    }
}

enum ColorDesc: String, CustomStringConvertible {
    case Blue, White, Black, Red
    
    var color: UIColor {
        switch self {
        case .Blue:  return UIColor.blueColor()
        case .White: return UIColor.whiteColor()
        case .Black: return UIColor.blackColor()
        case .Red:   return UIColor.redColor()
        }
    }
    
    var description: String {
        return self.rawValue
    }
}

///////////////////////////////////////////////////////
// MARK: - Main Styling Type
///////////////////////////////////////////////////////

/** Add additional global color or selected text styles to a give style. */
enum StyleDecorator: CustomStringConvertible {
    case Selection(String, FontDesc, SizeDesc, ColorDesc?)
    case Color(ColorDesc)
    
    var description: String {
        get {
            switch self {
            case .Color(let colorDesc): return "\(colorDesc)"
            case .Selection(let text, let fontDesc, let sizeDesc, let colorDesc):  return "(style \"\(text)\" with font \(fontDesc)/\(sizeDesc) color \(colorDesc!))"
            }
        }
    }
    
    var color: ColorDesc? {
        switch self {
        case .Color(let colorDesc): return colorDesc
        default: return nil
        }
    }
    
    var isSelection: Bool {
        switch self {
        case .Selection(_, _, _, _): return true
        default:                     return false
        }
    }
    
    var isColor: Bool {
        switch self {
        case .Color(_): return true
        default:        return false
        }
    }
}

/** The base style class to use.
 - Parameter font: - An enum value specifying the font.
 - Parameter fontSize: - The font size enum.
 - Parameter color: - The color enum.
 - Returns: A style object to be used with `applyStylingToElement`
 */

class Style: CustomStringConvertible {
    private let fontDesc:  FontDesc
    private let sizeDesc:  SizeDesc
    private let colorDesc: ColorDesc
    
    init(fontDesc: FontDesc, sizeDesc: SizeDesc, colorDesc: ColorDesc = ColorDesc.Black) {
        self.fontDesc  = fontDesc
        self.sizeDesc  = sizeDesc
        self.colorDesc = colorDesc
    }
    
    var description: String {
        return "\(fontDesc)(\(sizeDesc)) \(colorDesc)"
    }
    
    // MARK - Some sample convenience methods for illustration
    
    static var Headline1: Style {
        return Style(fontDesc: .Light, sizeDesc: .XXL)
    }
    
    static var Headline2: Style {
        return Style(fontDesc: .Light, sizeDesc: .Big)
    }
    
    static var Headline3: Style {
        return Style(fontDesc: .Light, sizeDesc: .Medium)
    }
    
    static var Copy: Style {
        return Style(fontDesc: .Light, sizeDesc: .Compact)
    }
    
    static var Caption2: Style {
        return Style(fontDesc: .Light, sizeDesc: .Small)
    }
    
    static var Caption1: Style {
        return Style(fontDesc: .Oblique, sizeDesc: .Small)
    }
    
    static var Footnote: Style {
        return Style(fontDesc: .Light, sizeDesc: .Tiny)
    }
    
    /** Provides a font for a given style.
     - Parameter style: A style from `Style`.
     - Returns: The font required by `style`. Falls back to a system font with a UIFontWeightTrait compatible defined in `FontDesc`.
     */
    static func fontForStyle (style: Style) -> UIFont {
        return UIFont(name: style.fontDesc.fontName, size: style.sizeDesc.fontSize) ?? UIFont.systemFontOfSize(17.0, weight: style.fontDesc.fontWeight)
    }
    
    
    /** Provides the attributes necessary for styling text as `NSAttributedString`.
     - Parameter style: A style from `Style`.
     - Returns: `NSFontAttributeName` and `NSForegroundColorAttributeName` values dictionary. Ignores `Style`.
     */
    static func baseAttributesForStyle (style: Style) -> [String : AnyObject] {
        return [NSFontAttributeName: Style.fontForStyle(style), NSForegroundColorAttributeName: style.colorDesc.color]
    }
}

/** A decorator object for applying global color as well as selected text settings.
 - Parameter style: - The base style object which should be decorated
 - Parameter options: - A decorator style. Only the last `DecoratorStyle.Color` element is applyied globally.
 - Returns: A style object to be used with `applyStylingToElement`.
 */

class DecoratedStyle: Style {
    let style: Style
    let options: [StyleDecorator]
    
    init(style: Style, options: StyleDecorator...) {
        self.style   = style
        self.options = options.filter{ $0.isSelection }
        
        let opColor = options.filter{ $0.isColor }.last?.color
        if let colorDesc = opColor {
            super.init(fontDesc: style.fontDesc, sizeDesc: style.sizeDesc, colorDesc: colorDesc)
        } else {
            super.init(fontDesc: style.fontDesc, sizeDesc: style.sizeDesc, colorDesc: style.colorDesc)
        }
    }
    
    override var description: String {
        get {
            let optionString = options.map({"\($0)"}).reduce(" - ") { $0 + $1 + " "}
            return super.description + optionString
        }
    }
}

///////////////////////////////////////////////////////
// MARK: - Extensions
///////////////////////////////////////////////////////

extension UIButton {
    func applyStyle (style: Style, forState state: UIControlState = UIControlState.Normal) {
        self.setTitleColor(style.colorDesc.color, forState: state)
        
        let title = self.titleForState(state)
        if let text = title {
            self.setAttributedTitle(NSAttributedString.attributedStringWithText(text, style: style), forState:state)
        } else {
            self.setAttributedTitle(NSAttributedString(string: ""), forState:state)
        }
    }
}

extension UILabel {
    /** Applies a style to a given `UILabel` object.
     If the `text` property is not empty, applies the style to the
     `attributedString` property, otherwise sets `font` and `textColor` properties.
     - Parameter label: The label to be styled.
     - Parameter style: The style information.
     */

    func applyStyle (style: Style) {
        self.font      = Style.fontForStyle(style)
        self.textColor = style.colorDesc.color
        
        if let text = self.text where text.isEmpty == false {
            self.attributedText = NSAttributedString.attributedStringWithText(text, style: style)
        }
    }
}

extension NSMutableAttributedString {
    func applyDecoratedStyle (style: StyleDecorator) {
        switch style {
        case .Color(let color):
            self.setAttributes([NSForegroundColorAttributeName: color.color], range: NSMakeRange(0, (self.string as NSString).length))
            
        case .Selection(let text, let font, let size, let color):
            let range = (self.string as NSString).rangeOfString(text)
            if range.location != NSNotFound {
                let style = Style(fontDesc: font, sizeDesc: size)
                var attributes: [String : AnyObject] = [NSFontAttributeName: Style.fontForStyle(style)]
                if let someColor = color?.color {
                    attributes[NSForegroundColorAttributeName] = someColor
                }
                self.setAttributes(attributes, range: range)
            }
        }
    }
}

extension NSAttributedString {
    static func attributedStringWithText(text: String, style: Style) -> NSAttributedString {
        let font = Style.fontForStyle(style)
        let color = style.colorDesc.color
        
        let mAttributedString = NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName: color
            ])
        
        if let attrStyle = style as? DecoratedStyle where attrStyle.options.isEmpty == false {
            for option in attrStyle.options {
                mAttributedString.applyDecoratedStyle(option)
            }
        }
        
        return mAttributedString
    }
}

