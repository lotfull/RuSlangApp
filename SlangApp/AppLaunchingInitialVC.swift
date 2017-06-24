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
                    word.definition = (returnNilIfNonNone(str: item_array[1]) == nil ? "No definition" : item_array[1]).uppercaseFirst()
                    word.type = returnNilIfNonNone(str: item_array[2])
                    word.group = returnNilIfNonNone(str: item_array[3])
                    word.examples = returnNilIfNonNone(str: item_array[4])
                    word.hashtags = returnNilIfNonNone(str: item_array[5])
                    word.origin = returnNilIfNonNone(str: item_array[6])
                    word.synonyms = returnNilIfNonNone(str: item_array[7])
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
                    word.definition = (returnNilIfNonNone(str: item_array[1]) == nil ? "No definition" : item_array[1]).uppercaseFirst()
                    word.type = returnNilIfNonNone(str: item_array[2])
                    word.group = returnNilIfNonNone(str: item_array[3])
                    word.examples = returnNilIfNonNone(str: item_array[4])
                    word.hashtags = returnNilIfNonNone(str: item_array[5])
                    word.origin = returnNilIfNonNone(str: item_array[6])
                    word.synonyms = returnNilIfNonNone(str: item_array[7])
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

    func returnNilIfNonNone(str: String) -> String? {
        if str == "NonNone" || str == "" || str == "_" || str == " " {
            return nil
        } else {
            return str
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showMainVCID {
            if let tabBarVC = segue.destination as? UITabBarController,
                let VControllers = tabBarVC.viewControllers as? [UINavigationController] {
                if let wordsTableVC = VControllers[0].topViewController as? WordsTableVC {
                    wordsTableVC.managedObjectContext = managedObjectContext
                } else {
                    fatalError("not correct window!.rootViewController as? UINavigationController unwrapping")
                }
                if let favoritesTableVC = VControllers[1].topViewController as? FavoritesTableVC {
                    favoritesTableVC.managedObjectContext = managedObjectContext
                } else {
                    fatalError("not correct window!.rootViewController as? UINavigationController unwrapping")
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
