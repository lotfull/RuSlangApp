//
//  WordViewController.swift
//  SlangApp
//
//  Created by Kam Lotfull on 11.03.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

class WordViewController: UIViewController {

    
    @IBOutlet weak var wordDefinitionLabel: UILabel!
    
    var wordName = "Слово Х"
    
    @IBOutlet weak var WordNameInBar: UINavigationItem!
    
    var wordDefinition = "Описание слова\nДовольно длинное значение\nДаже очень"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WordNameInBar.title = wordName
        wordDefinitionLabel.text = wordDefinition
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //name,type,group,definition,examples,hashtags,story
    
}
