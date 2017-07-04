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

class TrendsTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate, UITabBarControllerDelegate, AddingWordsToTrendsDelegate {
    
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        observeTrends()
        print("viewDidLoad")
        installTableView()
        self.tabBarController?.delegate = self
        selectedTabBarIndex = self.tabBarController?.selectedIndex
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tappedTabBarIndex = tabBarController.selectedIndex
        //print("previous: \(selectedTabBarIndex), tapped: \(tappedTabBarIndex)")
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
            print("prepare(for segue")
            if let wordDetailVC = segue.destination as? WordDetailVC {
                wordDetailVC.managedObjectContext = managedObjectContext
                wordDetailVC.word = selectedWord
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
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWord = trendWords[indexPath.row]
        print("didSelectRowAt")
        self.performSegue(withIdentifier: showWordDetailID, sender: nil)
    }
    
    // MARK: - Fetch funcs
    func observeTrends() {
        ref.child("trend words").observeSingleEvent(of: .value, with: { (snapshot) in
            self.trendWords = [Word]()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: String]
                let word = self.word(fromDict: dict)
                print("\(word.name)")
                self.trendWords.append(word)
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
    }
    
    func addToTrends(_ controller: WordDetailVC, word: Word) {
        print("delegate add to trends")
        
        //ref.child("trend words").child("3").setValue(["name": word.name])
    }
    
    // MARK: - WordTableViewCellDelegate
    func shareWord(_ controller: WordTableViewCell, word: Word) {
        let text = word.textViewString()
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    func reloading(_ controller: WordTableViewCell, indexPath: IndexPath) {
        do {
            try managedObjectContext.save()
        } catch {
            print ("There was managedObjectContext.save() error")
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
        func returnNilIfNonNone(_ str: String) -> String? {
            if str == "NonNone" || str == "" || str == "_" || str == " " {
                return nil
            } else {
                return str
            }
        }
        let word = Word(context: self.managedObjectContext)
        word.name = dictionary["name"]!
        word.definition = dictionary["definition"]!
        word.origin = returnNilIfNonNone(dictionary["origin"]!)
        word.group = returnNilIfNonNone(dictionary["group"]!)
        word.examples = returnNilIfNonNone(dictionary["examples"]!)
        word.synonyms = returnNilIfNonNone(dictionary["synonyms"]!)
        word.type = returnNilIfNonNone(dictionary["type"]!)
        word.hashtags = returnNilIfNonNone(dictionary["hashtags"]!)
        return word
    }
    
    @IBAction func reloadTrends(_ sender: Any) {
        observeTrends()
    }
    @IBAction func titleTapped(_ sender: Any) {
        scrollToHeader()
    }
    @IBOutlet weak var titleButton: UIButton!
    
    @IBAction func addTrends(_ sender: Any) {
        print("addTrends")
        //add_temp_trends()
    }
    
    // MARK: - VARS and LETS
    var managedObjectContext: NSManagedObjectContext!
    var trends = [String: Int]()
    var trendWords = [Word]()
    var selectedWord: Word!
    var selectedTabBarIndex: Int!
    var handleAdding: DatabaseHandle?
    var handleChanging: DatabaseHandle?
    var handle: DatabaseHandle?
    let showWordDetailID = "ShowWordDetail"
    let ref = Database.database().reference()
    
}