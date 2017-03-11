//
//  WordViewController.swift
//  SlangApp
//
//  Created by Kam Lotfull on 11.03.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

class WordViewController: UIViewController {

    
    
    @IBOutlet weak var wordLabel: UILabel!
    
    var wordName = "The Name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordLabel.text = wordName
        // Do any additional setup after loading the view.
    }
    
    

}
