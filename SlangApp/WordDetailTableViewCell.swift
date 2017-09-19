//
//  WordDetailTableViewCell.swift
//  SlangApp
//
//  Created by Kam Lotfull on 23.05.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

protocol WordDetailTableViewCellDelegate: class {
    //func shareWord(_ controller: WordTableViewCell, word: Word)
    func reloading(_ controller: WordDetailTableViewCell, indexPath: IndexPath)
}


class WordDetailTableViewCell: UITableViewCell, UITextViewDelegate {
    
    weak var delegate: WordDetailTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    var thisCellWord: Word!
    var thisCellIndexPath: IndexPath!
    
    @IBOutlet weak var wordTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        thisCellWord.favorite = !thisCellWord.favorite
        sender.imageView?.image = thisCellWord.favorite ? #imageLiteral(resourceName: "purpleStarFilled"): #imageLiteral(resourceName: "purpleStar")
        print("word is \(thisCellWord.favorite ? "" : "NOT ")favorite")
        delegate?.reloading(self, indexPath: thisCellIndexPath)
    }
    
    var number = 1
    
    func configurate(with word: Word, at indexPath: IndexPath) {
        self.wordTextView.delegate = self

        thisCellWord = word
        thisCellIndexPath = indexPath
        favoriteButton.imageView?.image = thisCellWord.favorite ? #imageLiteral(resourceName: "purpleStarFilled"): #imageLiteral(resourceName: "purpleStar")

        let wtv = wordTextView!
        let nameString = "\(word.name)\n"
        let attributedText = NSMutableAttributedString(string: nameString, attributes: [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: mainFontSize + 1),
            NSForegroundColorAttributeName: UIColor.blue])
        
        if word.type != nil {
            let typeString = "\(word.type!) "
            attributedText.append(NSAttributedString(string: typeString, attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: mainFontSize),
                NSForegroundColorAttributeName: UIColor.purple,
                NSParagraphStyleAttributeName: typeParagraphStyle]))
        }
        
        if word.group != nil {
            let groupString = "\(word.group!)"
            attributedText.append(NSAttributedString(string: groupString, attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: mainFontSize),
                NSForegroundColorAttributeName: UIColor.purple]))
        }
        
        let defString = "\n  \(number)) \(word.definition)\n"
        attributedText.append(NSAttributedString(string: defString, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: mainFontSize),
            NSForegroundColorAttributeName: UIColor.black,
            NSParagraphStyleAttributeName: defParagraphStyle]))
        
        if word.examples != nil {
            let examplesString = "примеры: \(word.examples!)\n"
            attributedText.append(NSMutableAttributedString(string: examplesString, attributes: [
                NSFontAttributeName: UIFont.italicSystemFont(ofSize: mainFontSize),
                NSForegroundColorAttributeName: UIColor.gray,
                NSParagraphStyleAttributeName: smallParagraphStyle]))
        }
        
        if word.origin != nil {
            let originString = "происх.: \(word.origin!)\n"
            attributedText.append(NSAttributedString(string: originString, attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: mainFontSize),
                NSForegroundColorAttributeName: UIColor.darkGray,
                NSParagraphStyleAttributeName: smallParagraphStyle]))
        }
        
        if word.synonyms != nil {
            let synonymsString = "син.: \(word.synonyms!)\n"
            attributedText.append(NSAttributedString(string: synonymsString, attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: mainFontSize),
                NSForegroundColorAttributeName: UIColor.darkGray,
                NSParagraphStyleAttributeName: smallParagraphStyle]))
        }
        
        if word.hashtags != nil {
            let hashtagsString = "\(word.hashtags!)"
            let hashtagsArray = hashtagsString.components(separatedBy: " ")
            let attributedString = NSMutableAttributedString(string: hashtagsString)
            var foundRange: NSRange
            for hashtag in hashtagsArray {
                if hashtag != "", hashtag != " " {
                    print(hashtag)
                    let translitHashtag = NSMutableString(string: hashtag)
                    CFStringTransform(translitHashtag, nil, kCFStringTransformToLatin, false)
                    print(translitHashtag)
                    CFStringTransform(translitHashtag, nil, kCFStringTransformStripDiacritics, false)
                    print(translitHashtag)
                    foundRange = attributedString.mutableString.range(of: hashtag)
                    attributedString.addAttribute(NSLinkAttributeName, value: translitHashtag, range: foundRange)
                }
            }
            attributedString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: mainFontSize),
                                           NSForegroundColorAttributeName: UIColor.purple,
                                           NSParagraphStyleAttributeName: hashParagraphStyle], range: attributedString.mutableString.range(of: hashtagsString))
            attributedText.append(attributedString)
            /*
            var foundRange = attributedString.mutableString.range(of: "Terms of use") //mention the parts of the attributed text you want to tap and get an custom action
            attributedString.addAttribute(NSLinkAttributeName, value: termsAndConditionsURL, range: foundRange)
            foundRange = attributedString.mutableString.range(of: "Privacy policy")
            attributedString.addAttribute(NSLinkAttributeName, value: privacyURL, range: foundRange)
            //wordTextView.attributedText = attributedString
            */
        }

        wtv.attributedText = attributedText
        wtv.isSelectable = true
        wtv.dataDetectorTypes = UIDataDetectorTypes.link
        wtv.isUserInteractionEnabled = true
        wtv.isEditable = false
    }
    
    var set = Set<String>()

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print(URL.absoluteString)
        return false
    }

    
    let smallParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 20
        paragraphStyle.paragraphSpacingBefore = 3
        return paragraphStyle
    }()
    
    let defParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.headIndent = 10
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacingBefore = 3
        return paragraphStyle
    }()
    
    let hashParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacingBefore = 3
        return paragraphStyle
    }()
    
    let typeParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.headIndent = 0
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacingBefore = 15
        return paragraphStyle
    }()
    
    let mainFontSize: CGFloat = 18
}

