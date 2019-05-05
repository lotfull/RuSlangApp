//
//  WordDetailTableViewCell.swift
//  SlangApp
//
//  Created by Kam Lotfull on 23.05.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

protocol WordDetailTableViewCellDelegate: class {
    //func shareWord(word: Word)
    func pop()
    func reloading(indexPath: IndexPath)
}

protocol SearchWordByHashtagDelegate: class {
    func updateSearch(_ wordName: String)
}

class WordDetailTableViewCell: UITableViewCell, UITextViewDelegate {
    
    weak var delegate: WordDetailTableViewCellDelegate?
    weak var delegate1: SearchWordByHashtagDelegate?
    
    var linkedWord = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var thisCellWord: Word!
    var thisCellIndexPath: IndexPath!
    var linkedWords: [String] = []
    
    @IBOutlet weak var wordTextView: UITextView!
    
    func configurate(with word: Word, wordsTVCRef: WordsTableVC, at indexPath: IndexPath) {
        linkedWords = [String]()
        self.delegate1 = wordsTVCRef
        self.wordTextView.delegate = self
        
        thisCellWord = word
        thisCellIndexPath = indexPath
        
        let wtv = wordTextView!
        let nameString = "\(word.name)\n"
        let attributedText = NSMutableAttributedString(string: nameString, attributes: convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize + 6),
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.blue]))
        
        if word.type != nil {
            let typeString = "\(word.type!)"
            attributedText.append(NSAttributedString(string: typeString, attributes: convertToOptionalNSAttributedStringKeyDictionary([
                convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize),
                convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.purple,
                convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): typeParagraphStyle])))
        }
        
        if word.group != nil {
            let groupString = (word.type != nil ? "\n" : "") + "\(word.group!)"
            attributedText.append(NSAttributedString(string: groupString, attributes: convertToOptionalNSAttributedStringKeyDictionary([
                convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize),
                convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.purple])))
        }
        
        let defString = "\n\(word.definition)\n"
        attributedText.append(NSAttributedString(string: defString, attributes: convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize),
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.black,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): defParagraphStyle])))
        
        if word.examples != nil {
            let examplesString = "примеры: \(word.examples!)\n"
            attributedText.append(NSMutableAttributedString(string: examplesString, attributes: convertToOptionalNSAttributedStringKeyDictionary([
                convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.italicSystemFont(ofSize: mainFontSize),
                convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.gray,
                convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): smallParagraphStyle])))
        }
        
        if word.origin != nil {
            let originString = "происх.: \(word.origin!)\n"
            attributedText.append(NSAttributedString(string: originString, attributes: convertToOptionalNSAttributedStringKeyDictionary([
                convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize),
                convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.darkGray,
                convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): smallParagraphStyle])))
        }
        
        if word.synonyms != nil {
            let synonymsString = "син.: \(word.synonyms!)\n"
            let seps = CharacterSet.init(charactersIn: ",. ")
            let synonymsArray = synonymsString.components(separatedBy: seps)
            let attributedString = NSMutableAttributedString(string: synonymsString)
            var foundRange: NSRange
            for synonym in synonymsArray {
                guard synonym.rangeOfCharacter(from: seps) == nil else {
                    continue
                }
                let synonymID = NSMutableString(string: "\(linkedWords.count)")
                linkedWords.append(synonym.uppercaseFirst())
                foundRange = attributedString.mutableString.range(of: synonym)
                attributedString.addAttribute(NSAttributedString.Key.link, value: synonymID, range: foundRange)
            }
            attributedString.addAttributes(convertToNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.darkGray, convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): smallParagraphStyle]), range: attributedString.mutableString.range(of: synonymsString))
            attributedText.append(attributedString)
        }
        
        if word.hashtags != nil {
            let hashtagsString = "\(word.hashtags!)\n"
            let hashtagsArray = hashtagsString.components(separatedBy: " ")
            let attributedString = NSMutableAttributedString(string: hashtagsString)
            var foundRange: NSRange
            for hashtag in hashtagsArray {
                guard hashtag != "", hashtag != " " else {
                    continue
                }
                let hashtagID = NSMutableString(string: "\(linkedWords.count)")
                linkedWords.append(hashtag)
                foundRange = attributedString.mutableString.range(of: hashtag)
                attributedString.addAttribute(NSAttributedString.Key.link, value: hashtagID, range: foundRange)
            }
            attributedString.addAttributes(convertToNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.purple, convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): hashParagraphStyle]), range: attributedString.mutableString.range(of: hashtagsString))
            attributedText.append(attributedString)
        }
        
        if word.link != nil {
            let linkString = "\(word.link!)\n"
            let url = URL(string: word.link!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            let attributedString = NSMutableAttributedString(string: linkString, attributes:[NSAttributedString.Key.link: url])
            attributedString.addAttributes(convertToNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.purple, convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): hashParagraphStyle]), range: attributedString.mutableString.range(of: linkString))
            attributedText.append(attributedString)
        }
        
        if word.video != nil {
            let linkString = "\(word.video!)"
            let url = URL(string: linkString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            let attributedString = NSMutableAttributedString(string: linkString, attributes:[NSAttributedString.Key.link: url])
            attributedString.addAttributes(convertToNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: mainFontSize), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.red, convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): hashParagraphStyle]), range: attributedString.mutableString.range(of: linkString))
            attributedText.append(attributedString)
        }
        
        wtv.attributedText = attributedText
        wtv.isSelectable = true
        wtv.dataDetectorTypes = UIDataDetectorTypes.link
        wtv.isUserInteractionEnabled = true
        wtv.isEditable = false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        print(url.absoluteString)
        if let linkedWordID = Int(url.absoluteString),
           linkedWords.count > linkedWordID {
            delegate1?.updateSearch(linkedWords[linkedWordID])
            if let initialVC = window!.rootViewController as? AppLaunchingInitialVC {
                initialVC.tabBarControl.selectedIndex = 0
            }
            delegate?.pop()
            return false
        } else {
            if !(url.absoluteString.starts(with: "http")) {
                UIApplication.shared.open(URL(string: "http://" + url.absoluteString)!)
            } else {
                UIApplication.shared.open(url)
            }
            return true
        }
    }
    
    let smallParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 30
        paragraphStyle.paragraphSpacingBefore = 10
        return paragraphStyle
    }()
    
    let defParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        paragraphStyle.headIndent = 0
//        paragraphStyle.firstLineHeadIndent = 20
        paragraphStyle.paragraphSpacingBefore = 10
        return paragraphStyle
    }()
    
    let hashParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        paragraphStyle.headIndent = 0
//        paragraphStyle.firstLineHeadIndent = 20
        paragraphStyle.paragraphSpacingBefore = 10
        return paragraphStyle
    }()
    
    let typeParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        paragraphStyle.headIndent = 0
//        paragraphStyle.firstLineHeadIndent = 15
        paragraphStyle.paragraphSpacingBefore = 20
        return paragraphStyle
    }()
    
    let mainFontSize: CGFloat = 16
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
