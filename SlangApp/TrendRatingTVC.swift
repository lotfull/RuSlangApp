//
//  TrendRatingTVC.swift
//  SlangApp
//
//  Created by Kam Lotfull on 12.09.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

protocol getTrendRatingDelegate: class {
    func trendRating(_ rating: Int)
}

class TrendRatingTVC: UITableViewController {
    
    weak var delegate: getTrendRatingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.trendRating(indexPath.row)
        _ = navigationController?.popViewController(animated: true)
    }
}
