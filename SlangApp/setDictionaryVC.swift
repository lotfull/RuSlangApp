//
//  setDictionaryVC.swift
//  SlangApp
//
//  Created by Lotfull on 22/04/2019.
//  Copyright © 2019 Kam Lotfull. All rights reserved.
//

import UIKit

protocol setDictionaryDelegate: class {
    func setDictionary(_ name: String)
}

class SetDictionaryVC: UITableViewController {
    
    weak var delegate: setDictionaryDelegate?
    var dictionaries: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath)
        cell.textLabel?.text = "\(self.dictionaries[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setDictionary(dictionaries[indexPath.row])
        _ = navigationController?.popViewController(animated: true)
    }
}
