//
//  ColorThemeTableViewController.swift
//  ColorThemeLab
//
//  Created by Danilo Campos on 5/22/19.
//  Copyright © 2019 Danilo Campos. All rights reserved.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

class NavigationController : UINavigationController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        if let topVC = viewControllers.last {
            //return the status property of each VC, look at step 2
            return topVC.preferredStatusBarStyle
        }
        
        return .default
    }
}

extension UIColor {
    convenience init(hexString:String) {
        let hexString:NSString = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) as NSString
        let scanner            = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

class ColorThemeTableViewController: UITableViewController, UITextFieldDelegate {
    
    enum HSVSections: Int, CaseIterable {
        case hue,
        saturation,
        brightness,
        storedColors
        
        func title() -> String {
            switch self {
            case .hue:
                return "Hue"
            case .saturation:
                return "Saturation"
            case .brightness:
                return "Brightness"
            case .storedColors:
                return "Saved Colors (swipe left to delete)"
            }
        }
    }
    
    enum ElementToStyle: Int {
        case button,
        title,
        bar
    }
    
    let storedColorCellReuseIdentifier = "colorCell"
    
    var sliderCells: Array<SliderTableViewCell>!
    var hueCell: SliderTableViewCell!
    var saturationCell: SliderTableViewCell!
    var brightnessCell: SliderTableViewCell!
    var selectedElement: ElementToStyle = .button
    
    var buttonColor: UIColor! {
        didSet {
            DefaultsManager.saveColor(color: buttonColor, forKey: .buttonColor)
        }
    }
    var titleTextColor: UIColor! {
        didSet {
            DefaultsManager.saveColor(color: titleTextColor, forKey: .titleColor)
        }
    }
    var barColor: UIColor! {
        didSet {
            DefaultsManager.saveColor(color: barColor, forKey: .barColor)
        }
    }
    
    var storedColors: Array<UIColor> = [] {
        didSet {
            DefaultsManager.saveStoredColors(colors: storedColors)
        }
    }
    
    var selectedColor: UIColor = UIColor.black {
        didSet {
            swatchView.backgroundColor = selectedColor
        }
    }
    
    @IBOutlet weak var hexField: UITextField!
    @IBOutlet weak var swatchView: UIView!
    
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet(newValue) {
            UIView.animate(withDuration: 0.25) {
                self.navigationController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    @IBOutlet weak var elementSelector: UISegmentedControl!
    
    func updateGradients() {
        let hue = CGFloat(hueCell.slider!.value)
        let saturation = CGFloat(saturationCell.slider!.value)
        let brightness = CGFloat(brightnessCell.slider!.value)
        
        var hueColors: Array<CGColor> = []
        
        for index in 0...10 {
            hueColors.append(UIColor(hue: CGFloat(index) * 0.1, saturation: saturation, brightness: brightness, alpha: 1.0).cgColor)
        }
        
        hueCell.gradientColors = hueColors
        
        
        let saturationColors = [UIColor(hue: hue, saturation: 0.0, brightness: brightness, alpha: 1.0).cgColor,
        UIColor(hue: hue, saturation: 1.0, brightness: brightness, alpha: 1.0).cgColor]
        
        saturationCell.gradientColors = saturationColors
        
        let brightnessColors = [UIColor(hue: hue, saturation: saturation, brightness: 0.0, alpha: 1.0).cgColor, UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0).cgColor]
        
        brightnessCell.gradientColors = brightnessColors
        
        selectedColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        
        switch selectedElement {
        case .button:
            navigationController?.navigationBar.tintColor = selectedColor
            elementSelector.tintColor = selectedColor
            buttonColor = selectedColor
        case .title:
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: selectedColor]
            titleTextColor = selectedColor
        case .bar:
            navigationController?.navigationBar.barTintColor = selectedColor
            barColor = selectedColor
            
            if (brightness < 0.4) {
                statusBarStyle = .lightContent
            } else {
                statusBarStyle = .default
            }
        }
        
        hexField.text = selectedColor.toHexString().uppercased()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    fileprivate func updateSliders() {
        
        switch selectedElement {
        case .button:
            selectedColor = buttonColor
        case .title:
            selectedColor = titleTextColor
        case .bar:
            selectedColor = barColor
        }
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        selectedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        hueCell.slider.setValue(Float(hue), animated: true)
        saturationCell.slider.setValue(Float(saturation), animated: true)
        brightnessCell.slider.setValue(Float(brightness), animated: true)
        
        updateGradients()
        
    }
    
    @IBAction func handleToggle(_ sender: UISegmentedControl) {
        selectedElement = ElementToStyle(rawValue: sender.selectedSegmentIndex)!
        
        updateSliders()
    }
    
    @IBAction func handleColorSave(_ sender: Any) {
        storedColors.insert(selectedColor, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: HSVSections.storedColors.rawValue)], with: .top)
    }
    
    
    fileprivate func saveColors() {
        DefaultsManager.saveColor(color: buttonColor, forKey: DefaultsKeys.buttonColor)
        DefaultsManager.saveColor(color: titleTextColor, forKey: DefaultsKeys.titleColor)
        DefaultsManager.saveColor(color: barColor, forKey: DefaultsKeys.barColor)
        
        DefaultsManager.saveStoredColors(colors: storedColors)
    }
    
    fileprivate func updateForNewColor(_ newColor: UIColor) {
        
        selectedColor = newColor
        
        switch selectedElement {
        case .button:
            buttonColor = newColor
        case .title:
            titleTextColor = newColor
        case .bar:
            barColor = newColor
        }

        updateSliders()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let newColor = UIColor.init(hexString: textField.text!)
        
        updateForNewColor(newColor)
        
        textField.resignFirstResponder()
        
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hueCell = SliderTableViewCell.fromNib()
        saturationCell = SliderTableViewCell.fromNib()
        brightnessCell = SliderTableViewCell.fromNib()
        
        sliderCells = [hueCell, saturationCell, brightnessCell]
        
        updateGradients()
        
        for cell in sliderCells {
            cell.sliderDidChange = {
                self.updateGradients()
            }
        }
    
        tableView.register(UINib.init(nibName: "StoredColorTableViewCell", bundle: nil), forCellReuseIdentifier: storedColorCellReuseIdentifier)
        
        title = "Title Label"
        
        swatchView.layer.borderColor = UIColor.black.cgColor
        swatchView.layer.borderWidth = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let color = DefaultsManager.colorForKey(.buttonColor) {
            buttonColor = color
        } else {
            buttonColor = elementSelector.tintColor
        }
        
        if let color = DefaultsManager.colorForKey(.titleColor) {
            titleTextColor = color
        } else {
            titleTextColor = UIColor.darkGray
        }
        
        if let color = DefaultsManager.colorForKey(.barColor) {
            barColor = color
        } else {
            barColor = UIColor(white: 0.95, alpha: 1.0)
        }
        
        storedColors = DefaultsManager.storedColors()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        updateSliders()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return HSVSections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
        case HSVSections.storedColors.rawValue:
            return storedColors.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == HSVSections.storedColors.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: storedColorCellReuseIdentifier, for: indexPath) as! StoredColorTableViewCell
            
            let color = storedColors[indexPath.row]
            
            cell.label.text = color.toHexString()
            cell.colorSwatchView.backgroundColor = color
            
            return cell
        } else {
            return sliderCells[indexPath.section]
        }
            
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return HSVSections(rawValue: section)!.title()
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case HSVSections.storedColors.rawValue:
            return true
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == HSVSections.storedColors.rawValue {
            updateForNewColor(storedColors[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case HSVSections.storedColors.rawValue:
            return true
        default:
            return false
        }
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            storedColors.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
