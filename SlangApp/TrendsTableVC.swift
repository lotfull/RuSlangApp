//
//  TrendsTableVC.swift
//  SlangApp
//
//  Created by Kam Lotfull on 25.06.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//


import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import Dispatch

class TrendsTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate, UITabBarControllerDelegate, AddingWordsToTrendsDelegate, SendingFeedbackDelegate, AddingNewWordsToFirebase {
    // MARK: - VARS and LETS
    let delegate = UIApplication.shared.delegate as? AppDelegate
    lazy var managedObjectContext: NSManagedObjectContext = {
        return (delegate?.managedObjectContext)!
    }()
    var wordsTableVCRef: WordsTableVC!
    var trends = [String: Int]()
    var trendWords = [Word]()
    var selectedWord: Word!
    var selectedTabBarIndex: Int!
    var handleAdding: DatabaseHandle?
    var handleChanging: DatabaseHandle?
    var handle: DatabaseHandle?
    let showWordDetailID = "ShowWordDetail"
    let ref = Database.database().reference()
    let maxTrendsNum = 10
    
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        observeTrends()
        //print("viewDidLoad")
        installTableView()
        self.tabBarController?.delegate = self
        selectedTabBarIndex = self.tabBarController?.selectedIndex
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tappedTabBarIndex = tabBarController.selectedIndex
        if tappedTabBarIndex == selectedTabBarIndex {
            scrollToHeader()
        }
        selectedTabBarIndex = tappedTabBarIndex
    }
    
    func scrollToHeader() {
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    func installTableView() {
        tableView.register(UINib.init(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "Word")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWordDetailID {
            if let wordDetailVC = segue.destination as? WordDetailVC {
                wordDetailVC.word = selectedWord
                wordDetailVC.wordsTableVCRef = wordsTableVCRef
            }
        }
    }
    
    // MARK: - TableView Funcs
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendsCell", for: indexPath)
        cell.textLabel?.text = trendWords[indexPath.row].name
        cell.detailTextLabel?.text = trendWords[indexPath.row].definition
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWord = trendWords[indexPath.row]
        //print("didSelectRowAt")
        self.performSegue(withIdentifier: showWordDetailID, sender: nil)
    }
    
    // MARK: - Fetch funcs
    func observeTrends() {
        ref.child("trend words").observeSingleEvent(of: .value, with: { (snapshot) in
            self.trendWords = [Word]()
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: String] {
                    let word = self.word(fromDict: dict)
                    self.trendWords.append(word)
                }
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
    }
    
    func sendFeedback(_ controller: FeedbackVC, _ feedback: Feedback) {
        ref.child("feedbacks").childByAutoId().setValue([
            "contacts": feedback.contacts,
            "feedback": feedback.feedback,
            "rating": feedback.rating])
    }
    
    func addNewWord(_ word: Word) {
        ref.child("new words").childByAutoId().setValue([
            "name": word.name,
            "definition": word.definition,
            "origin": word.origin,
            "group": word.group,
            "examples": word.examples,
            "synonyms": word.synonyms,
            "type": word.type,
            "hashtags": word.hashtags,
            "wordId": word.wordId])
    }
    
    func editWord(_ word: Word) {
        ref.child("edit words").childByAutoId().setValue([
            "id": String(word.wordId),
            "name": word.name,
            "definition": word.definition,
            "origin": word.origin,
            "group": word.group,
            "examples": word.examples,
            "synonyms": word.synonyms,
            "type": word.type,
            "hashtags": word.hashtags])
    }
    
    func addToTrends(_ controller: WordDetailVC, word: Word, rating: Int) {
        if Int(word.wordId)! > 100000 {
            ref.child("trend words").child("\(rating)").setValue([
                "name": word.name,
                "definition": word.definition,
                "origin": word.origin,
                "group": word.group,
                "examples": word.examples,
                "synonyms": word.synonyms,
                "type": word.type,
                "hashtags": word.hashtags])
            observeTrends()
        } else {
            ref.child("trend words").child("\(rating)").setValue([
                "wordId": word.wordId,
                "name": word.name,
                "definition": word.definition,
                "origin": word.origin,
                "group": word.group,
                "examples": word.examples,
                "synonyms": word.synonyms,
                "type": word.type,
                "hashtags": word.hashtags
                ])
            observeTrends()
        }
    }
    
    // MARK: - WordTableViewCellDelegate
    
    func shareWord(word: Word) {
        shareWordFunc()
        let text = word.textViewString()
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func reloading(indexPath: IndexPath) {
        do {
            try managedObjectContext.save()
        } catch {
            print("There was managedObjectContext.save() error")
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("error tableView(_ tableView: UITableView, commit editingStyle \(error)")
        }
    }
    
    
    func word(fromDict dictionary: [String: String]) -> Word {
        print(dictionary)
        if let wordId = dictionary["wordId"],
            let word = delegate!.words.first(where: { (word) -> Bool in
                return word.wordId == wordId
            }) {
            return word
        }
        
        func returnNilIfNonNone(_ str: String?) -> String? {
            if str == "NonNone" || str == "" || str == "_" || str == " " {
                return nil
            } else {
                return str
            }
        }
        
        let word = Word(context: self.managedObjectContext)
        word.name = dictionary["name"]!
        word.definition = dictionary["definition"]!
        word.origin = returnNilIfNonNone(dictionary["origin"])
        word.group = returnNilIfNonNone(dictionary["group"])
        word.examples = returnNilIfNonNone(dictionary["examples"])
        word.synonyms = returnNilIfNonNone(dictionary["synonyms"])
        word.type = returnNilIfNonNone(dictionary["type"])
        word.hashtags = returnNilIfNonNone(dictionary["hashtags"])
        word.wordId = Word.newWordId()
        return word
    }
    
//    func word(fromWordId wordId: Int) -> Word? {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        let managedObjectContext = (delegate?.managedObjectContext)!
//        let searchFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
//        searchFetch.predicate = NSPredicate(format: "wordId == %i", wordId)
//        do {
//            let words = try managedObjectContext.fetch(searchFetch) as! [Word]
//            if words.count == 1 {
//                return words[0]
//            }
//        } catch {
//            fatalError("Failed to fetch words: \(error)")
//        }
//        return nil
//    }
    
    @IBAction func reloadTrends(_ sender: Any) {
        observeTrends()
    }
    
    @IBAction func titleTapped(_ sender: Any) {
        scrollToHeader()
    }
    
    @IBOutlet weak var titleButton: UIButton!
    
    @IBAction func addTrends(_ sender: Any) {
    }
}
