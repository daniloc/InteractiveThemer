//
//  SliderTableViewCell.swift
//  ColorThemeLab
//
//  Created by Danilo Campos on 5/23/19.
//  Copyright © 2019 Danilo Campos. All rights reserved.
//

import UIKit
import CoreGraphics

class SliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var slider: UISlider!
    
    var sliderDidChange: (()-> Void)?
    
    var gradientColors: Array<CGColor>! {
        didSet {
            updateGradient()
        }
    }
    
    func updateGradient() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: slider.frame.size.width, height: 10.0)
        gradientLayer.frame = frame
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.0, y:0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0)
        
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        
        if var image = UIGraphicsGetImageFromCurrentImageContext() {
            
            UIGraphicsEndImageContext()
            
            image = image.resizableImage(withCapInsets: UIEdgeInsets.zero)
            
            slider.setMinimumTrackImage(image, for: .normal)
            slider.setMaximumTrackImage(image, for: .normal)
        }
        
    }

    @IBAction func handleSlider(_ sender: Any) {
        if let handler = sliderDidChange {
            handler()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
