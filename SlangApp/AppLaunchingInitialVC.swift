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
    
    // MARK: - VARS and LETS
    var managedObjectContext: NSManagedObjectContext!
    var tabBarControl: UITabBarController!
    let showMainVCID = "ShowMainVC"
    let isPreloadedKey = "isPreloaded"
    let wordsVersion = "1"
    let teenslang = "teenslang-1"
    let vsekidki = "vsekidki-2"
    let modnyeslova = "modnyeslova"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let defaults = UserDefaults.standard
            //defaults.set(false, forKey: "isPreloaded")
            let isPreloaded = defaults.bool(forKey: self.isPreloadedKey + self.wordsVersion)
            if !isPreloaded {
                self.preloadDataFromCSVFile()
                defaults.set(true, forKey: self.isPreloadedKey + self.wordsVersion)
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.showMainVCID, sender: nil)
            }
        }
    }
    
    func preloadDataFromCSVFile() {
        removeData()
        let dictionaryNameToId = [
            "teenslang-1": 1,
            "vsekidki-1": 2,
            "vsekidki-2": 3,
            "modnyeslova": 4
        ]
        for appwordsFile in ["teenslang-1", "vsekidki-1", "vsekidki-2", "modnyeslova"] {
            print("Processing \(appwordsFile)")
            if let contentsOfURL = Bundle.main.url(forResource: appwordsFile, withExtension: "csv") {
                if let content = try? String(contentsOf: contentsOfURL, encoding: String.Encoding.utf8) {
                    let items_arrays = content.csvRows(firstRowIgnored: true)
                    for item_array in items_arrays {
                        let word = NSEntityDescription.insertNewObject(forEntityName: "Word", into: managedObjectContext) as! Word
                        if appwordsFile == "vsekidki-2" {
                            word.name = item_array[2].uppercaseFirst()
                            word.definition = (nilIfEmpty(item_array[1]) == nil ? "Нет определения" : item_array[1]).uppercaseFirst()
                            word.group = nilIfEmpty(item_array[3])
                            word.origin = nilIfEmpty("http://vsekidki.ru/" + item_array[0])
                        } else if appwordsFile == "modnyeslova" {
                            // definition,link,name,video
                            word.name = item_array[2].uppercaseFirst()
                            word.definition = item_array[0]
                            word.examples = nilIfEmpty(item_array[3])
                            word.origin = nilIfEmpty(item_array[1])
                            word.dictionaryId =
                        } else {
                            word.name = item_array[0].uppercaseFirst()
                            word.definition = (nilIfEmpty(item_array[1]) == nil ? "Нет определения" : item_array[1]).uppercaseFirst()
                            word.type = nilIfEmpty(item_array[2])
                            word.group = nilIfEmpty(item_array[3])
                            word.examples = nilIfEmpty(item_array[4])
                            word.hashtags = nilIfEmpty(item_array[5])
                            word.origin = nilIfEmpty(item_array[6])
                            word.synonyms = nilIfEmpty(item_array[7])
                        }
                    }
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print("**********insert error: \(error.localizedDescription)\n********")
                    }
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
            print("There was an error")
        }
    }
    
    func nilIfEmpty(_ str: String) -> String? {
        return (str == "" || str == "_" || str == " ") ? nil : str
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showMainVCID {
            guard let tabBarVC = segue.destination as? UITabBarController,
                  let VControllers = tabBarVC.viewControllers as? [UINavigationController],
                  let wordsTableVC = VControllers[0].topViewController as? WordsTableVC,
                  let trendsVC = VControllers[1].topViewController as? TrendsTableVC,
                  let favoritesTableVC = VControllers[2].topViewController as? FavoritesTableVC,
                  let moreVC = VControllers[3].topViewController as? MoreVC else {
                fatalError("*****not correct window!.rootViewController as? UINavigationController unwrapping")
            }
            tabBarControl = tabBarVC
            wordsTableVC.managedObjectContext = managedObjectContext
            wordsTableVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
            trendsVC.managedObjectContext = managedObjectContext
            trendsVC.wordsTableVCRef = wordsTableVC
            favoritesTableVC.managedObjectContext = managedObjectContext
            favoritesTableVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
            favoritesTableVC.wordsTableVCRef = wordsTableVC
            moreVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
            moreVC.wordsVC = VControllers[0].topViewController as? WordsTableVC
        }
    }
}
