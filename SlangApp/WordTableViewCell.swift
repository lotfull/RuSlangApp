//
//  WordTableViewCell.swift
//  SlangApp
//
//  Created by Kam Lotfull on 24.03.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var wordNameLabel: UILabel!
    
    @IBOutlet weak var wordDefinitionLabel: UILabel!
    
    
    @IBAction func readMoreButton(_ sender: UIButton) {
    }

    @IBOutlet weak var isFavoriteWordSwitch: UISwitch!
    
    
    func configure(with word: Word) {
        wordNameLabel.text = word.name
        if word.definition.isEmpty {
            wordDefinitionLabel.text = "(No Definition)"
        } else {
            wordDefinitionLabel.text = word.definition
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
