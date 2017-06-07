//
//  WordTableViewCell.swift
//  SlangApp
//
//  Created by Kam Lotfull on 24.03.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

protocol WordTableViewCellDelegate: class {
    func shareWord(_ controller: WordTableViewCell, word: Word)
    func reloading(_ controller: WordTableViewCell, indexPath: IndexPath)
}

class WordTableViewCell: UITableViewCell {
    
    weak var delegate: WordTableViewCellDelegate?
    
    @IBOutlet weak var wordNameLabel: UILabel!
    
    @IBOutlet weak var wordDefinitionLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    func configure(with word: Word, at indexPath: IndexPath) {
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        thisCellWord = word
        thisCellIndexPath = indexPath
        wordNameLabel.text = word.name
        if word.definition.isEmpty {
            wordDefinitionLabel.text = "(No Definition)"
        } else {
            wordDefinitionLabel.text = word.definition
        }
        favoriteButton.imageView?.image = word.favorite ? #imageLiteral(resourceName: "big yellow star ") : #imageLiteral(resourceName: "big star ")
    }

    var thisCellWord: Word!
    var thisCellIndexPath: IndexPath!
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        thisCellWord.favorite = !thisCellWord.favorite
        favoriteButton.imageView?.image = thisCellWord.favorite ? #imageLiteral(resourceName: "big yellow star ") : #imageLiteral(resourceName: "big star ")
        delegate?.reloading(self, indexPath: thisCellIndexPath)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shareWordButton(_ sender: Any) {
        delegate?.shareWord(self, word: thisCellWord)
    }


}
