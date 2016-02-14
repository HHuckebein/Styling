# Styling
___
 
You usually use *UIAppearance* methods to consistent styling througout your App, do you?
Thats fine as long as you have only static styling. As soon as you need a dynamic styling
behaviour you have to use other means to get the job done, as appearance is applied **before**
your object gets added to the view hierarchy.

Styling is a sample implementation to keep all your font/color settings in one place. It is easy
to understand and could easily be extended. 



It provides methods to apply a style (`UIButton`/`UILabel`), generate an `NSAttributedString` or
modify an `NSMutableAttributedString`.
 
### `UIButton`

```swift
func applyStyle (style: Style, forState state: UIControlState = UIControlState.Normal)
```

### `UILabel`

```swift
func applyStyle (style: Style)
```

### `NSAttributedText`

```swift
static func attributedStringWithText(text: String, style: Style) -> NSAttributedString
```

### `NSMutableAttributedText`

```swift
func applyDecoratedStyle (style: StyleDecorator)
```

-------------------

## How to use it?
There are three enum types you have to fill with your style needs.
1. FontDesc
2. SizeDesc
3. ColorDesc

So if you need to style the string *"The quick brown fox jumps over the lazy dog."* where the "*fox"*
and *"dog"* should have a different styling you create the style as follows:

```swift
let baseStyle = Style(fontDesc: fontDesc, sizeDesc: .Big, colorDesc: .Blue)
let foxStyle  = StyleDecorator.Selection("fox", .NeueBold, .XXL, .Black)
let dogStyle  = StyleDecorator.Selection("dog", .Oblique, .Small, .Red)

let decoratedStyle = DecoratedStyle(style: baseStyle, options: foxStyle, dogStyle)

"The quick brown fox jumps over the lazy dog.".applyStyle(decoratedStyle)
```
The Styles type provides some template methods for styles you use often.

```swift
 yourLabel.applyStyle(Style.Headline)
```

## What you should know

1. If you provide more than one ColorDesc as option to a DecoratedStyle the last color option wins.
2. The `static func fontForStyle (style: Style)` always gives you a font back. If the font defined in your style can't
be found, it falls back to a similar system font.
3. Styling of attributed text is limited to font an color.



