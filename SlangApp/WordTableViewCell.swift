//
//  WordTableViewCell.swift
//  SlangApp
//
//  Created by Kam Lotfull on 24.03.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

protocol WordTableViewCellDelegate: class {
    func shareWord(word: Word)
    func reloading(indexPath: IndexPath)
}

class WordTableViewCell: UITableViewCell {
    // MARK: - VARS and LETS
    var addNewWord = false
    var thisCellWord: Word!
    var thisCellIndexPath: IndexPath!
    weak var delegate: WordTableViewCellDelegate?
    
    func configure(with word: Word, at indexPath: IndexPath) {
        addNewWord = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        thisCellWord = word
        thisCellIndexPath = indexPath
        wordNameLabel.text = thisCellWord.name
        if thisCellWord.definition.isEmpty {
            wordDefinitionLabel.text = "Нет определения"
        } else {
            wordDefinitionLabel.text = thisCellWord.definition
        }
        favoriteButton.imageView?.image = (thisCellWord.favorite ? #imageLiteral(resourceName: "star-4") : #imageLiteral(resourceName: "star-3")).withRenderingMode(.alwaysTemplate)
        shareButton.imageView?.image = shareButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        shareButton.adjustsImageWhenHighlighted = false
        shareButton.tintColor = (UIApplication.shared.delegate as? AppDelegate)!.appColor
    }
    
    func configure(withName: String, withDefinition: String, at indexPath: IndexPath) {
        addNewWord = true
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        thisCellIndexPath = indexPath
        wordNameLabel.text = withName
        wordDefinitionLabel.text = withDefinition
        shareButton.tintColor = (UIApplication.shared.delegate as? AppDelegate)!.appColor
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if !addNewWord {
            thisCellWord.favorite = !thisCellWord.favorite
            favoriteButton.imageView?.image = (thisCellWord.favorite ? #imageLiteral(resourceName: "star-4") : #imageLiteral(resourceName: "star-3")).withRenderingMode(.alwaysTemplate)
            delegate?.reloading(indexPath: thisCellIndexPath)
        }
    }
    
    @IBAction func shareWordButton(_ sender: Any) {
        if !addNewWord {
            delegate?.shareWord(word: thisCellWord)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordDefinitionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
}
