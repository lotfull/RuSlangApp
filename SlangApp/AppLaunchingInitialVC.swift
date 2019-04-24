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
    let teenslang = "teenslang2"
    let vsekidki = "vsekidki2"
    let modnyeslova = "modnyeslova"
    let all = "all"
    lazy var dictionaries = [teenslang, vsekidki, modnyeslova, all]
    lazy var dictionaryNames = [
        teenslang: "Teenslang.su",
        vsekidki: "Vsekidki.ru",
        modnyeslova: "Модные-слова.рф",
        all: "Словарь сленг-слов"
    ]
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isPreloaded")
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
        
        for dictionaryFile in dictionaries {
            print("Processing \(dictionaryFile)")
            if let contentsOfURL = Bundle.main.url(forResource: dictionaryFile, withExtension: "csv"),
                let content = try? String(contentsOf: contentsOfURL, encoding: String.Encoding.utf8) {
                let items_arrays = content.csvRows(firstRowIgnored: true)
                print("items_arrays.count:", items_arrays.count)
                for item_array in items_arrays {
                    let word = NSEntityDescription.insertNewObject(forEntityName: "Word", into: managedObjectContext) as! Word
                    word.dictionaryId = dictionaries.firstIndex(of: dictionaryFile)!
                    switch dictionaryFile {
                    case teenslang:
                        // definition,examples,group,hashtags,name,origin,synonyms,type
                        print(0, separator: "", terminator: "")
                        word.definition = (nilIfEmpty(item_array[0]) == nil ? "Нет определения" : item_array[1]).uppercaseFirst()
                        word.examples = nilIfEmpty(item_array[1])
                        word.group = nilIfEmpty(item_array[2])
                        word.hashtags = nilIfEmpty(item_array[3])
                        word.name = item_array[4].uppercaseFirst()
                        word.origin = nilIfEmpty(item_array[5])
                        word.synonyms = nilIfEmpty(item_array[6])
                        word.type = item_array.count == 8 ? nilIfEmpty(item_array[7]) : nil
                    case vsekidki:
                        print(1, separator: "", terminator: "")
                        word.name = item_array[2].uppercaseFirst()
                        word.definition = (nilIfEmpty(item_array[1]) == nil ? "Нет определения" : item_array[1]).uppercaseFirst()
                        word.group = nilIfEmpty(item_array[3])
                        word.origin = nilIfEmpty("http://vsekidki.ru/" + item_array[0])
                    case modnyeslova:
                        print(2, separator: "", terminator: "")
                        // definition,link,name,video
                        word.name = item_array[2].uppercaseFirst()
                        word.definition = item_array[0]
                        word.examples = item_array.count == 4 ? nilIfEmpty(item_array[3]) : nil
                        word.origin = nilIfEmpty(item_array[1])
                    default: break
                    }
                }
            } else {
                print("Fuck \(dictionaryFile)")
            }
            do {
                try managedObjectContext.save()
            } catch {
                print("**********insert error: \(error.localizedDescription)\n********")
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
            wordsTableVC.dictionaries = self.dictionaries
            wordsTableVC.dictionaryNames = self.dictionaryNames
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

