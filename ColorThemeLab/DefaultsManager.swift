//
//  DefaultsManager.swift
//  ColorThemeLab
//
//  Created by Danilo Campos on 5/29/19.
//  Copyright © 2019 Danilo Campos. All rights reserved.
//

import UIKit

enum DefaultsKeys: String {
    case buttonColor = "buttonColor",
    titleColor = "titleColor",
    barColor = "barColor",
    storedColors = "storedColors"
}

extension UserDefaults {
    
    func color(forKey key: String) -> UIColor? {
        
        guard let colorData = data(forKey: key) else { return nil }
        
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func set(_ value: UIColor?, forKey key: String) {
        
        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }
        
    }
    //via: https://stackoverflow.com/a/30576832/150181
}



class DefaultsManager {
    
    
    class func saveColor(color: UIColor?, forKey: DefaultsKeys) {
        
        if let color = color {
            UserDefaults.standard.set(color, forKey: forKey.rawValue)
        }
    }
    
    class func colorForKey(_ key: DefaultsKeys) -> UIColor? {
        return UserDefaults.standard.color(forKey: key.rawValue)
    }
    
    class func saveStoredColors(colors: Array<UIColor>) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: colors, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: DefaultsKeys.storedColors.rawValue)
        }
    }
    
    class func storedColors() -> Array<UIColor> {
        
        guard let data = UserDefaults.standard.data(forKey: DefaultsKeys.storedColors.rawValue) else { return [] }
        
        if let colors = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Array<UIColor> {
            return colors
        } else {
            return []
        }
        
        
    }
}
