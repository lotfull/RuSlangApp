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
    var addNewWord = false
    
    func configure(with word: Word, at indexPath: IndexPath) {
        addNewWord = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        thisCellWord = word
        thisCellIndexPath = indexPath
        wordNameLabel.text = /*String(word.id) + " " + */thisCellWord.name
        if thisCellWord.definition.isEmpty {
            wordDefinitionLabel.text = "Нет определения"
        } else {
            wordDefinitionLabel.text = thisCellWord.definition
        }
        favoriteButton.imageView?.image = thisCellWord.favorite ? #imageLiteral(resourceName: "purpleStarFilled") : #imageLiteral(resourceName: "purpleStar")
        //print("\nconfigure thisCellIndexPath: \(thisCellIndexPath.row)")
        //print("configure thisCellWord.name: \(thisCellWord.name), favourite: \(thisCellWord.favorite)")
        favoriteButton.imageView?.image = thisCellWord.favorite ? #imageLiteral(resourceName: "purpleStarFilled") : #imageLiteral(resourceName: "purpleStar")

    }
    
    func configure(withName: String, withDefinition: String, at indexPath: IndexPath) {
        addNewWord = true
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        thisCellIndexPath = indexPath
        wordNameLabel.text = withName
        wordDefinitionLabel.text = withDefinition
        favoriteButton.imageView?.image = #imageLiteral(resourceName: "purpleStar")
    }

    var thisCellWord: Word!
    var thisCellIndexPath: IndexPath!
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if !addNewWord {
            thisCellWord.favorite = !thisCellWord.favorite
            favoriteButton.imageView?.image = thisCellWord.favorite ? #imageLiteral(resourceName: "purpleStarFilled") : #imageLiteral(resourceName: "purpleStar")
            //print("\nthisCellIndexPath: \(thisCellIndexPath.row)")
            //print("thisCellWord.name: \(thisCellWord.name), favourite: \(thisCellWord.favorite)")
            delegate?.reloading(self, indexPath: thisCellIndexPath)
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
    
    @IBAction func shareWordButton(_ sender: Any) {
        if !addNewWord {
            delegate?.shareWord(self, word: thisCellWord)
        }
    }


}
