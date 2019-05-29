//
//  StoredColorTableViewCell.swift
//  ColorThemeLab
//
//  Created by Danilo Campos on 5/29/19.
//  Copyright © 2019 Danilo Campos. All rights reserved.
//

import UIKit

class StoredColorTableViewCell: UITableViewCell {

    @IBOutlet weak var colorSwatchView: UIView!
    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorSwatchView.layer.borderWidth = 1.0
        colorSwatchView.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
