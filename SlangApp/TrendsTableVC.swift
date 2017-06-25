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

class TrendsTableVC: UITableViewController, UITextFieldDelegate, WordTableViewCellDelegate, UITabBarControllerDelegate {
    
    let ref = Database.database().reference()
    var handleAdding: DatabaseHandle?
    var handleChanging: DatabaseHandle?
    var handle: DatabaseHandle?
    
    @IBAction func titleTapped(_ sender: Any) {
        scrollToHeader()
    }
    @IBOutlet weak var titleButton: UIButton!
    
    @IBAction func addTrends(_ sender: Any) {
        print("addTrends")
        add_temp_trends()
    }
    
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstTrendsFetch()
        //trendsFetch()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath) as! WordTableViewCell
        cell.configure(with: trendWords[indexPath.row], at: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWord = trendWords[indexPath.row]
        print("didSelectRowAt")
        self.performSegue(withIdentifier: showWordDetailID, sender: nil)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    // MARK: - Fetch funcs
    func add_temp_trends() {
        ref.child("trend words").child("rand \(arc4random())").setValue(arc4random())
        
    }
    
    func firstTrendsFetch() {
        handle = ref.child("trend words").observe(.value, with: { (snapshot) in
            print("handle value")
            if let snapDict = snapshot.value as? [String:Int] {
                print("SNAPDICT: \(snapDict)")
                self.trends = snapDict
                self.trendWords = [Word]()
                for trend in snapDict {
                    let word = Word(context: self.managedObjectContext)
                    word.name = trend.key
                    word.definition = "\(trend.value)"
                    self.trendWords.append(word)
                }
            } else {
                print("failed if let", snapshot.value)
            }
            self.tableView.reloadData()
        })
    }
    
    func trendsFetch() {
        handleAdding = ref.child("trend words").observe(.childAdded, with: { (snapshot) in
            print("handle adding")
            if let snapDict = snapshot.value as? [String:Int] {
                if let trend = snapDict.first {
                    self.trends[trend.key] = trend.value
                    let word = Word(context: self.managedObjectContext)
                    word.name = trend.key
                    word.definition = "\(trend.value)"
                    self.trendWords.append(word)
                }
            }
            self.tableView.reloadData()
        })
    }
        /*
        handleChanging = ref.child("trend words").observe(.childChanged, with: { (snapshot) in
            print("childChanged")
            if let trendsDict = snapshot.value as? [String: Int] {
                for trend in trendsDict {
                    self.trends[trend.key] = trend.value
                    print(trend)
                    let word = Word(context: self.managedObjectContext)
                    word.name = trend.key
                    word.definition = "\(trend.value)"
                    self.trendWords.append(word)
                }
                self.tableView.reloadData()
            }
        })
*/
        
        
        /*let nameBeginsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        do {
            words = try managedObjectContext.fetch(nameBeginsFetch) as! [Word]
        } catch {
            fatalError("Failed to fetch words: \(error)")
        }
        filteredWords = words
         tableView.reloadData()*/ // last fetching

    
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        managedObjectContext.delete(trendWords[indexPath.row])
        saveManagedObjectContext()
        trendWords.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("error tableView(_ tableView: UITableView, commit editingStyle \(error)")
        }
    }
    
    // MARK: - VARS and LETS
    var managedObjectContext: NSManagedObjectContext!
    var trendWords = [Word]()
    var trends = [String: Int]()
    var selectedWord: Word!
    var selectedTabBarIndex: Int!
    let showWordDetailID = "ShowWordDetail"
}
