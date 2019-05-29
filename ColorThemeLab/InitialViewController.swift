//
//  InitialViewController.swift
//  ColorThemeLab
//
//  Created by Danilo Campos on 5/22/19.
//  Copyright © 2019 Danilo Campos. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let colorTableViewController = ColorThemeTableViewController.init(nibName: nil, bundle: nil)
        
        navigationController?.pushViewController(colorTableViewController, animated: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
