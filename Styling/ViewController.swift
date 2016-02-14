import UIKit
import CoreText

class ViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeForFirstAppearance()
    }
    
    // MARK: Private API
    
    private var style : Style = Style.Headline1 {
        didSet {
            textLabel.applyStyle(style)
        }
    }
    
    private var selectedIndexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0) {
        didSet {
            style = updateCurrentStyle()
        }
    }
    
    private lazy var dataSourcePicker: Array<String>? = {
        var allFonts = UIFont.familyNames() as [String]
        let dataSourcePicker = allFonts.filter{ $0.rangeOfString("Helvetica") != nil }
        
        return dataSourcePicker
    }()
    
    private var dataSourceTableView: Array<UIFontDescriptor>? {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            delay(0.25) { () -> () in
                self.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: true, scrollPosition: .Top)
                self.selectedIndexPath = NSIndexPath(forItem: 0, inSection: 0)
            }
        }
    }
    
    // MARK: Helper

    private func currentFontDescriptor () -> FontDesc {
        var fontDesc: FontDesc = .Light
        if let dataSource = dataSourceTableView, let fontName = dataSource[selectedIndexPath.item].objectForKey(UIFontDescriptorNameAttribute) as? String {
            if let desc = FontDesc(rawValue: fontName) {
                fontDesc = desc
            }
        }
        return fontDesc
    }
    
    private func updateCurrentStyle () -> Style {
        let fontDesc = currentFontDescriptor()
        let baseStyle = Style(fontDesc: fontDesc, sizeDesc: .Big, colorDesc: .Blue)
        let foxStyle  = StyleDecorator.Selection("fox", .NeueBold, .XXL, .Black)
        let dogStyle  = StyleDecorator.Selection("dog", .Oblique, .Small, .Red)
        
        return DecoratedStyle(style: baseStyle, options: foxStyle, dogStyle)
    }
    
    private func styleForFontName(fontName: String, sizeDesc: SizeDesc) -> Style {
        if let fontDesc = FontDesc(rawValue: fontName) {
            return Style(fontDesc: fontDesc, sizeDesc: sizeDesc)
        } else {
            return Style(fontDesc: .Light, sizeDesc: sizeDesc)
        }
    }
    
    private func customizeForFirstAppearance () {
        // disable empty cell display
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.textLabel.text = "The quick brown fox jumps over the lazy dog"
        updateTableViewDataSourceForIndex(0)
    }
    
    private func fontLabelForPickerView (pickerView: UIPickerView, familyName: String?) -> UILabel {
        let label       = UILabel(frame: CGRectMake(30, 0, CGRectGetWidth(pickerView.bounds) - 30, 30))
        label.text      = familyName ?? ""
        label.font      = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.textColor = UIColor.blackColor()
        
        return label
    }
    
    private func updateTableViewDataSourceForIndex (index: Int) {
        if let familiyName = dataSourcePicker?[index] {
            let customFontFamily = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute: familiyName])
            dataSourceTableView = customFontFamily.matchingFontDescriptorsWithMandatoryKeys(nil) as Array<UIFontDescriptor>
        }
    }
    
    private func configureCell (cell: UITableViewCell, index: Int) -> Bool {
        if let descriptor = dataSourceTableView?[index], let fontName = descriptor.fontAttributes()[UIFontDescriptorNameAttribute] as? String {
            cell.textLabel?.text       = fontName
            cell.detailTextLabel?.text = "size \(SizeDesc.Medium.fontSize)"
            
            cell.textLabel?.applyStyle(styleForFontName(fontName, sizeDesc: .Medium))
            cell.detailTextLabel?.applyStyle(styleForFontName(fontName, sizeDesc: .Tiny))
            
            return true
        }
        return false
    }
}

// MARK: - UITableViewDataSource/UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceTableView?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubtitleCell", forIndexPath: indexPath)
        return configureCell(cell, index: indexPath.row) ? cell : UITableViewCell(frame: CGRectZero)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
    }
}

// MARK: UIPickerView Provider

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateTableViewDataSourceForIndex(row)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSourcePicker?.count ?? 0
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        return fontLabelForPickerView(pickerView, familyName: dataSourcePicker?[row])
    }
    
}
