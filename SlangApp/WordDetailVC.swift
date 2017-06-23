//
//  WordDetailVC.swift
//  SlangApp
//
//  Created by Kam Lotfull on 21.05.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import CoreData
import UIKit

class WordDetailVC: UITableViewController, WordDetailTableViewCellDelegate, CreateWordVCDelegate {
    // MARK: - MAIN FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = true
        title = word.name
        tblView.estimatedRowHeight = tableView.rowHeight
        tblView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100//tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == editWordID {
            if let navigationController = segue.destination as? UINavigationController,
            let createEditWordVC = navigationController.topViewController as? CreateEditWordVC {
                createEditWordVC.managedObjectContext = managedObjectContext
                createEditWordVC.editingWord = word
                createEditWordVC.delegate = self
                //wordDetailVC.word = selectedWord
            }
        }
    }
    
    // MARK: - CreateWordVCDelegate
    func createEditWordVCDidCancel(_ controller: CreateEditWordVC) {
        dismiss(animated: true, completion: nil)
    }
    
    func createEditWordVCDone(_ controller: CreateEditWordVC, adding word: Word) {
        tableView.reloadData()
        saveManagedObjectContext()
        dismiss(animated: true, completion: nil)
    }
    
    func createEditWordVCDone(_ controller: CreateEditWordVC, editing word: Word) {
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save() // <- remember to put this :)
        } catch {
            fatalError("error tableView(_ tableView: UITableView, commit editingStyle \(error)")
        }
    }
    
    // MARK: - TABLEVIEW FUNCS
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordDetailCell", for: indexPath) as! WordDetailTableViewCell
        cell.configurate(with: word, at: indexPath)
        cell.delegate = self
        return cell
    }
    
    func reloading(_ controller: WordDetailTableViewCell, indexPath: IndexPath) {
        do {
            try managedObjectContext.save()
        } catch {
            print ("There was managedObjectContext.save() error")
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - @IBO and @IBA
    @IBAction func shareWordButton(_ sender: Any) {
        // text to share
        let text = word.textViewString()
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ ]
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        needToUpdate = false
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet var tblView: UITableView!
    
    // MARK: - VARS and LETS
    var managedObjectContext: NSManagedObjectContext!
    var word: Word!
    let editWordID = "EditWord"
}















