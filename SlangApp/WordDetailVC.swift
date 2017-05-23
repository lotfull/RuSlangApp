//
//  WordDetailVC.swift
//  SlangApp
//
//  Created by Kam Lotfull on 21.05.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import CoreData
import UIKit

class WordDetailVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = word.name
        wordTextView.text = "\(word.name)\n\n  \(word.definition)\n    \"\(word.examples!)\" \n Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        tblView.estimatedRowHeight = 74
        tblView.rowHeight = UITableViewAutomaticDimension
    }
    //@IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
      //  dismiss(animated: true, completion: nil)
    //}
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    //@IBOutlet weak var wordTextView: UITextView!
    
    var managedObjectContext: NSManagedObjectContext!
    var word: Word!
    
    @IBOutlet weak var wordTextView: UITextView!
    @IBOutlet var tblView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}















