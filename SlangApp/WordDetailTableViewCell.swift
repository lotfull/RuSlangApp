//
//  WordDetailTableViewCell.swift
//  SlangApp
//
//  Created by Kam Lotfull on 23.05.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

class WordDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBOutlet weak var wordTextView: UITextView!
    
    func configurate(with word: Word) {
        let wtv = wordTextView!
        
        let nameString = "\(word.name)\n\n"
        let attributedText = NSMutableAttributedString(string: nameString, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.blue])
        
        if word.type != nil {
            let typeString = "\(word.type!) "
            attributedText.append(NSAttributedString(string: typeString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.green]))
        }
        if word.group != nil {
            let groupString = "\(word.group!) "
            attributedText.append(NSAttributedString(string: groupString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.green]))
        }
        
        let defString = "\n  1) \(word.definition)\n"
        attributedText.append(NSAttributedString(string: defString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.black]))
        
        if word.examples != nil {
            let examplesString = "    прим.: \(word.examples!)\n"
            attributedText.append(NSAttributedString(string: examplesString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.gray]))
        }
        
        if word.origin != nil {
            let originString = "  происх.: \(word.origin!)\n"
            attributedText.append(NSAttributedString(string: originString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.darkGray]))
        }
        
        if word.synonyms != nil {
            let synonymsString = "  син.: \(word.synonyms!)\n"
            attributedText.append(NSAttributedString(string: synonymsString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.darkGray]))
        }
        
        if word.hashtags != nil {
            let hashtagsString = "\n  \(word.hashtags!) "
            attributedText.append(NSAttributedString(string: hashtagsString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.green]))
        }
        
        wtv.attributedText = attributedText
        
        wtv.isSelectable = true
        wtv.dataDetectorTypes = UIDataDetectorTypes.link
        wtv.isUserInteractionEnabled = true
        wtv.isEditable = false
        //wtv.text = word.name + word.definition
        // wtv.backgroundColor = .yellow
        
        //name, definition, type, group, examples, hashtags, story, synonims

    }
}
 
