//
//  MoreVC.swift
//  SlangApp
//
//  Created by Kam Lotfull on 08.09.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

class MoreVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFeedbackView" {
            if let feedbackVC = segue.destination as? FeedbackVC {
                feedbackVC.delegate = trendsVC
            }
        }
    }
    
    var trendsVC: TrendsTableVC!
    var wordsVC: WordsTableVC!
    
}
