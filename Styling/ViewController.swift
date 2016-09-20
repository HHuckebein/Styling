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
    
    fileprivate var style : Style = Style.Headline1 {
        didSet {
            textLabel.apply(style: style)
        }
    }
    
    fileprivate var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0) {
        didSet {
            style = updateCurrentStyle()
        }
    }
    
    fileprivate lazy var dataSourcePicker: Array<String>? = {
        var allFonts = UIFont.familyNames as [String]
        let dataSourcePicker = allFonts.filter{ $0.range(of: "Helvetica") != nil }
        
        return dataSourcePicker
    }()
    
    fileprivate var dataSourceTableView: Array<UIFontDescriptor>? {
        didSet {
            tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
            delay(0.25) { () -> () in
                self.tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
                self.selectedIndexPath = IndexPath(item: 0, section: 0)
            }
        }
    }
    
    // MARK: Helper

    fileprivate func currentFontDescriptor () -> FontDesc {
        var fontDesc: FontDesc = .Light
        if let dataSource = dataSourceTableView, let fontName = dataSource[(selectedIndexPath as NSIndexPath).item].object(forKey: UIFontDescriptorNameAttribute) as? String {
            if let desc = FontDesc(rawValue: fontName) {
                fontDesc = desc
            }
        }
        return fontDesc
    }
    
    fileprivate func updateCurrentStyle () -> Style {
        let fontDesc = currentFontDescriptor()
        let baseStyle = Style(fontDesc: fontDesc, sizeDesc: .big, colorDesc: .Blue)
        let foxStyle  = StyleDecorator.selection("fox", .NeueBold, .xxl, .Black)
        let dogStyle  = StyleDecorator.selection("dog", .Oblique, .small, .Red)
        
        return DecoratedStyle(style: baseStyle, options: foxStyle, dogStyle)
    }
    
    fileprivate func styleForFontName(_ fontName: String, sizeDesc: SizeDesc) -> Style {
        if let fontDesc = FontDesc(rawValue: fontName) {
            return Style(fontDesc: fontDesc, sizeDesc: sizeDesc)
        } else {
            return Style(fontDesc: .Light, sizeDesc: sizeDesc)
        }
    }
    
    fileprivate func customizeForFirstAppearance () {
        // disable empty cell display
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.textLabel.text = "The quick brown fox jumps over the lazy dog"
        updateTableViewDataSourceForIndex(0)
    }
    
    fileprivate func fontLabelForPickerView (_ pickerView: UIPickerView, familyName: String?) -> UILabel {
        let label       = UILabel(frame: CGRect(x: 30, y: 0, width: pickerView.bounds.width - 30, height: 30))
        label.text      = familyName ?? ""
        label.font      = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        label.textColor = UIColor.black
        
        return label
    }
    
    fileprivate func updateTableViewDataSourceForIndex (_ index: Int) {
        if let familiyName = dataSourcePicker?[index] {
            let customFontFamily = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute: familiyName])
            dataSourceTableView = customFontFamily.matchingFontDescriptors(withMandatoryKeys: nil) as Array<UIFontDescriptor>
        }
    }
    
    fileprivate func configureCell (_ cell: UITableViewCell, index: Int) -> Bool {
        if let descriptor = dataSourceTableView?[index], let fontName = descriptor.fontAttributes[UIFontDescriptorNameAttribute] as? String {
            cell.textLabel?.text       = fontName
            cell.detailTextLabel?.text = "size \(SizeDesc.medium.fontSize)"
            
            cell.textLabel?.apply(style: styleForFontName(fontName, sizeDesc: .medium))
            cell.detailTextLabel?.apply(style: styleForFontName(fontName, sizeDesc: .tiny))
            
            return true
        }
        return false
    }
}

// MARK: - UITableViewDataSource/UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceTableView?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)
        return configureCell(cell, index: (indexPath as NSIndexPath).row) ? cell : UITableViewCell(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
}

// MARK: UIPickerView Provider

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateTableViewDataSourceForIndex(row)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSourcePicker?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return fontLabelForPickerView(pickerView, familyName: dataSourcePicker?[row])
    }
    
}
