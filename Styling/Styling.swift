//
//  Styling.swift
//
//
//  Created by Bernd Rabe on 10.06.15.
//  Copyright (c) 2015 RABE_IT Services. All rights reserved.
//

import UIKit

/** Encapsulates the used font types.
 */
public enum FontDesc: String, CustomStringConvertible {
    /** Corresponds to HelveticaNeue-Light */
    case NeueLight    = "HelveticaNeue-Light"

    /** Corresponds to HelveticaNeue-Medium */
    case NeueMedium   = "HelveticaNeue-Medium"

    /** Corresponds to HelveticaNeue-Bold */
    case NeueBold     = "HelveticaNeue-Bold"
    
    /** Corresponds to HelveticaNeue */
    case NeueRegular  = "HelveticaNeue"
    
    /** Corresponds to Helvetica */
    case Regular      = "Helvetica"
    
    /** Corresponds to HelveticaNeue-Light */
    case Light        = "Helvetica-Light"
    
    /** Corresponds to HelveticaNeue-Oblique */
    case Oblique      = "Helvetica-Oblique"

    /** Corresponds to HelveticaNeue-LightOblique */
    case LightOblique = "Helvetica-LightOblique"
    
    /** A corresponding font weight. Used to return a suitable
        system font if a custom font can't be found.
     */
    var fontWeight: CGFloat {
        switch self {
        case .Light, .NeueLight:         return UIFontWeightLight
        case .Regular, .NeueRegular:     return UIFontWeightRegular
        case .NeueBold, .Oblique:        return UIFontWeightBold
        case .NeueMedium, .LightOblique: return UIFontWeightMedium
        }
    }
    
    /** FontDesc Description */
    public var description: String {
        return "FontDesc: fontName: \(fontName)"
    }
    
    var fontName: String {
        return self.rawValue
    }
}

/** Encapsulates the used font sizes.
 */
public enum SizeDesc: CGFloat, CustomStringConvertible {
    /** Corresponds size 10.0 pt */
    case tiny    = 10.0
    
    /** Corresponds size 12.0 pt */
    case small   = 12.0
    
    /** Corresponds size 14.0 pt */
    case compact = 14.0
    
    /** Corresponds size 16.0 pt */
    case medium  = 16.0
    
    /** Corresponds size 20.0 pt */
    case big     = 20.0
    
    /** Corresponds size 40.0 pt */
    case xxl     = 40.0
    
    var fontSize: CGFloat {
        return self.rawValue
    }

    /** SizeDesc Description */
    public var description: String {
        return "ColorDesc: \(self.rawValue)pt"
    }
}

/** Encapsulates the used colors.
 */
public enum ColorDesc: String, CustomStringConvertible {
    /** Corresponds to system blue color */
    case Blue
    
    /** Corresponds to system white color */
    case White
    
    /** Corresponds to system black color */
    case Black
    
    /** Corresponds to system red color */
    case Red
    
    var color: UIColor {
        switch self {
        case .Blue:  return .blue
        case .White: return .white
        case .Black: return .black
        case .Red:   return .red
        }
    }
    
    /** ColorDesc Description */
    public var description: String {
        return self.rawValue
    }
}

///////////////////////////////////////////////////////
// MARK: - Main Styling Type
///////////////////////////////////////////////////////

/** A decorator which can be used to add an additional global color
    or selected text styles to a give style.
 */
public enum StyleDecorator: CustomStringConvertible {
    case selection(String, FontDesc, SizeDesc, ColorDesc?)
    case Color(ColorDesc)
    
    /** StyleDecorator Description */
    public var description: String {
        switch self {
        case .Color(let colorDesc): return "\(colorDesc)"
        case .selection(let text, let fontDesc, let sizeDesc, let colorDesc):  return "(style \"\(text)\" with font \(fontDesc)/\(sizeDesc) color \(colorDesc!))"
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
        case .selection(_, _, _, _): return true
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
 Initialized with `fontDesc`, `sizeDesc` and `colorDesc` or
 by using predefined convenience styles.
 
 - Parameter font: - An enum value specifying the font.
 - Parameter fontSize: - The font size enum.
 - Parameter color: - The color enum.
 - Returns: A style object to be used with `applyStylingToElement`
 */

open class Style: CustomStringConvertible {
    fileprivate let fontDesc:  FontDesc
    fileprivate let sizeDesc:  SizeDesc
    fileprivate let colorDesc: ColorDesc
    
    init(fontDesc: FontDesc, sizeDesc: SizeDesc, colorDesc: ColorDesc = ColorDesc.Black) {
        self.fontDesc  = fontDesc
        self.sizeDesc  = sizeDesc
        self.colorDesc = colorDesc
    }
    
    /** Style Description */
    open var description: String {
        return "\(fontDesc)(\(sizeDesc)) \(colorDesc)"
    }
    
    // MARK - Some sample convenience methods for illustration
    
    /** Headline1: .Light, .XXL */
    open static var Headline1: Style {
        return Style(fontDesc: .Light, sizeDesc: .xxl)
    }
    
    /** Headline1: .Light, .Big */
    open static var Headline2: Style {
        return Style(fontDesc: .Light, sizeDesc: .big)
    }
    
    /** Headline1: .Light, .Medium */
    open static var Headline3: Style {
        return Style(fontDesc: .Light, sizeDesc: .medium)
    }
    
    /** Headline1: .Light, .Compact */
    open static var Copy: Style {
        return Style(fontDesc: .Light, sizeDesc: .compact)
    }
    
    /** Headline1: .Light, .Small */
    open static var Caption2: Style {
        return Style(fontDesc: .Light, sizeDesc: .small)
    }
    
    /** Headline1: .Oblique, .Small */
    open static var Caption1: Style {
        return Style(fontDesc: .Oblique, sizeDesc: .small)
    }
    
    /** Headline1: .Light, .Tiny */
    open static var Footnote: Style {
        return Style(fontDesc: .Light, sizeDesc: .tiny)
    }
    
    /** Provides a font for a given style.
     
     - Parameter style: A style from `Style`.
     - Returns: The font required by `style`. Falls back to a system font with a UIFontWeightTrait compatible defined in `FontDesc`.
     */
    open static func font (for style: Style) -> UIFont {
        return UIFont(name: style.fontDesc.fontName, size: style.sizeDesc.fontSize) ?? UIFont.systemFont(ofSize: 17.0, weight: style.fontDesc.fontWeight)
    }
    
    
    /** Provides the attributes necessary for styling text as `NSAttributedString`.
     
     - Parameter style: A style from `Style`.
     - Returns: `NSFontAttributeName` and `NSForegroundColorAttributeName` values dictionary. Ignores `Style`.
     */
    open static func baseAttributes (for style: Style) -> [String : AnyObject] {
        return [NSFontAttributeName: Style.font(for: style), NSForegroundColorAttributeName: style.colorDesc.color]
    }
}

/** A decorator object for applying global color as well as selected text settings.
 
 - Parameter style: - The base style object which should be decorated
 - Parameter options: - A decorator style. Only the last `DecoratorStyle.Color` element is applyied globally.
 - Returns: A style object to be used with `applyStylingToElement`.
 */

open class DecoratedStyle: Style {
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
    
    /** DecoratedStyle Description */
    open override var description: String {
        let optionString = options.map({"\($0)"}).reduce(" - ") { $0 + $1 + " "}
        return super.description + optionString
    }
}

// MARK: - Extensions

public extension UIButton {
/** Applies a style to a given `UIButton` object where it sets the
 title attribute for a given control state.
 
 - Parameter style: The style information.
 - Parameter state: The `UIControlState` where the style should be applied to.
 */
    func apply (style: Style, for state: UIControlState = UIControlState()) {
        self.setTitleColor(style.colorDesc.color, for: state)
        
        let title = self.title(for: state)
        if let text = title {
            self.setAttributedTitle(NSAttributedString.attributedString(with: text, style: style), for:state)
        } else {
            self.setAttributedTitle(NSAttributedString(string: ""), for:state)
        }
    }
}

public extension UILabel {
/** Applies a style to a given `UILabel` object.
 If the `text` property is not empty, applies the style to the
 `attributedString` property, otherwise sets `font` and `textColor` properties.
 
 - Parameter label: The label to be styled.
 - Parameter style: The style information.
 */

    func apply (style: Style) {
        self.font      = Style.font(for: style)
        self.textColor = style.colorDesc.color
        
        if let text = self.text , text.isEmpty == false {
            self.attributedText = NSAttributedString.attributedString(with: text, style: style)
        }
    }
}

public extension NSMutableAttributedString {
    /** Applies a style decorator to a NSMutableAttributedString object.
     Depending on wether it is a .Color or .Selection decorator, sets
     foreground color or the style for the text selection.
     
     - Parameter style: The style object.
    */
    func applyDecorated (style: StyleDecorator) {
        switch style {
        case .Color(let color):
            self.setAttributes([NSForegroundColorAttributeName: color.color], range: NSMakeRange(0, (self.string as NSString).length))
            
        case .selection(let text, let font, let size, let color):
            let range = (self.string as NSString).range(of: text)
            if range.location != NSNotFound {
                let style = Style(fontDesc: font, sizeDesc: size)
                var attributes: [String : AnyObject] = [NSFontAttributeName: Style.font(for: style)]
                if let someColor = color?.color {
                    attributes[NSForegroundColorAttributeName] = someColor
                }
                self.setAttributes(attributes, range: range)
            }
        }
    }
}

public extension NSAttributedString {
    /** Provides an attributed string for a given style.
    Limited to the options the `Style` class provides.
     
     - Parameter text: The inpunt text.
     - Parameter style: The style object.
     - Returns: An NSAttributedString object.
    */
    static func attributedString(with text: String, style: Style) -> NSAttributedString {
        let font = Style.font(for: style)
        let color = style.colorDesc.color
        
        let mAttributedString = NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName: color
            ])
        
        if let attrStyle = style as? DecoratedStyle , attrStyle.options.isEmpty == false {
            for option in attrStyle.options {
                mAttributedString.applyDecorated(style: option)
            }
        }
        
        return mAttributedString
    }
}

