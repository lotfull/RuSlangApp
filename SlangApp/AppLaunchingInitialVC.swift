//
//  AppLaunchingInitialVC.swift
//  SlangApp
//
//  Created by Kam Lotfull on 24.06.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import Foundation
import UIKit
import Dispatch
import CoreData

class AppLaunchingInitialVC: UIViewController {
        
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
        // Asynchronous, with quality of class
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let defaults = UserDefaults.standard
            //defaults.set(false, forKey: "isPreloaded")
            let isPreloaded = defaults.bool(forKey: self.isPreloadedKey)
            if !isPreloaded {
                self.preloadDataFromCSVFile()
                defaults.set(true, forKey: self.isPreloadedKey)
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.showMainVCID, sender: nil)
                self.activityIndicator.color = UIColor.purple
                //self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func preloadDataFromCSVFile() {
        removeData()
        if let contentsOfURL = Bundle.main.url(forResource: teenslang, withExtension: "csv") {
            print("teenslang Nigga!")
            if let content = try? String(contentsOf: contentsOfURL, encoding: String.Encoding.utf8) {
                let items_arrays = content.csvRows(firstRowIgnored: true)
                for item_array in items_arrays {
                    let word = NSEntityDescription.insertNewObject(forEntityName: "Word", into: managedObjectContext) as! Word
                    word.name = item_array[0].uppercaseFirst()
                    word.definition = (returnNilIfEmpty(item_array[1]) == nil ? "Нет определения" : item_array[1]).uppercaseFirst()
                    word.type = returnNilIfEmpty(item_array[2])
                    word.group = returnNilIfEmpty(item_array[3])
                    word.examples = returnNilIfEmpty(item_array[4])
                    word.hashtags = returnNilIfEmpty(item_array[5])
                    word.origin = returnNilIfEmpty(item_array[6])
                    word.synonyms = returnNilIfEmpty(item_array[7])
                    word.id = Int(item_array[8])!
                }
                do {
                    try managedObjectContext.save()
                } catch {
                    print("**********insert error: \(error.localizedDescription)\n********")
                }
            }
        }
        if let contentsOfURL = Bundle.main.url(forResource: vsekidki, withExtension: "csv") {
            print("vsekidki Nigga!")
            if let content = try? String(contentsOf: contentsOfURL, encoding: String.Encoding.utf8) {
                let items_arrays = content.csvRows(firstRowIgnored: true)
                for item_array in items_arrays {
                    let word = NSEntityDescription.insertNewObject(forEntityName: "Word", into: managedObjectContext) as! Word
                    word.name = item_array[0].uppercaseFirst()
                    word.definition = (returnNilIfEmpty(item_array[1]) == nil ? "Нет определения" : item_array[1]).uppercaseFirst()
                    word.type = returnNilIfEmpty(item_array[2])
                    word.group = returnNilIfEmpty(item_array[3])
                    word.examples = returnNilIfEmpty(item_array[4])
                    word.origin = returnNilIfEmpty(item_array[5])
                    word.hashtags = returnNilIfEmpty(item_array[6])
                    word.synonyms = returnNilIfEmpty(item_array[7])
                    word.id = Int(item_array[8])!
                }
                do {
                    try managedObjectContext.save()
                } catch {
                    print("**********insert error: \(error.localizedDescription)\n********")
                }
            }
        }
    }
    

    func removeData() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try managedObjectContext.execute(request)
            try managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
    }

    func returnNilIfEmpty(_ str: String) -> String? {
        return (str == "" || str == "_" || str == " ") ? nil : str
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showMainVCID {
            if let tabBarVC = segue.destination as? UITabBarController,
                let VControllers = tabBarVC.viewControllers as? [UINavigationController] {
                if let wordsTableVC = VControllers[0].topViewController as? WordsTableVC {
                    wordsTableVC.managedObjectContext = managedObjectContext
                    wordsTableVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
                } else {
                    fatalError("*****not correct window!.rootViewController as? UINavigationController unwrapping")
                }
                if let trendsVC = VControllers[1].topViewController as? TrendsTableVC {
                    trendsVC.managedObjectContext = managedObjectContext
                } else {
                    fatalError("*****not correct window!.rootViewController as? UINavigationController unwrapping")
                }
                if let favoritesTableVC = VControllers[2].topViewController as? FavoritesTableVC {
                    favoritesTableVC.managedObjectContext = managedObjectContext
                    favoritesTableVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
                } else {
                    fatalError("*****not correct window!.rootViewController as? UINavigationController unwrapping")
                }
                if let moreVC = VControllers[3].topViewController as? MoreVC {
                    moreVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
                    moreVC.wordsVC = VControllers[0].topViewController as? WordsTableVC
                }
            }
        }
    }
    
    var managedObjectContext: NSManagedObjectContext!
    let showMainVCID = "ShowMainVC"
    let isPreloadedKey = "isPreloaded"
    let teenslang = "teenslang_appwords"
    let vsekidki = "vsekidki_appwords"
    
}
