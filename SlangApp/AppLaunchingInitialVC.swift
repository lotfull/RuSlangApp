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
    let delegate = UIApplication.shared.delegate as? AppDelegate
    lazy var managedObjectContext: NSManagedObjectContext = {
        return (delegate?.managedObjectContext)!
    }()
    var tabBarControl: UITabBarController!
    let showMainVCID = "ShowMainVC"
    let isPreloadedKey = "isPreloaded"
    let wordsVersion = "2"
    let dictionaryFile = "full_dict"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var firstInstallLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let defaults = UserDefaults.standard
            let isPreloaded = defaults.bool(forKey: self.isPreloadedKey + self.wordsVersion)
            if !isPreloaded {
                self.activityIndicator.isHidden = false
                self.firstInstallLabel.isHidden = false
                self.preloadDataFromCSVFile()
                defaults.set(true, forKey: self.isPreloadedKey + self.wordsVersion)
            }
            self.fetchWords()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.showMainVCID, sender: nil)
            }
        }
    }
    
    func fetchWords() {
        let nameBeginsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        nameBeginsFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        do {
            delegate!.words = (try managedObjectContext.fetch(nameBeginsFetch) as! [Word])
            let sliceStart = delegate!.words.firstIndex { (word: Word) -> Bool in
                return word.name[word.name.startIndex] == "А"
            }
            let start = Int(sliceStart!), prev=start-1
            delegate!.words = delegate!.words[start...] + Array(delegate!.words[...prev])
        } catch {
            fatalError("Failed to fetch words: \(error)")
        }
    }
    
    func preloadDataFromCSVFile() {
        var methodStart = Date()
        
        removeData()
        
        if let contentsOfURL = Bundle.main.url(forResource: dictionaryFile, withExtension: "csv"),
           let content = try? String(contentsOf: contentsOfURL, encoding: String.Encoding.utf8) {
            let items_arrays = content.csvRows(firstRowIgnored: true)
            print("items_arrays.count:", items_arrays.count)
            for item_array in items_arrays {
                let word = NSEntityDescription.insertNewObject(forEntityName: "Word", into: managedObjectContext) as! Word
//              'name', 'definition', 'link', 'id', 'group', 'examples', 'hashtags', 'origin', 'synonyms', 'type', 'dict_id', 'video'
                let values = item_array.map(nilIfEmpty)
                word.name = values[0]!
                word.definition = values[1] == nil ? "Нет определения" : values[1]!
                word.link = values[2]
                word.wordId = values[3]!
                word.group = values[4]
                word.examples = values[5]
                word.hashtags = values[6]
                word.origin = values[7]
                word.synonyms = values[8]
                word.type = values[9]
                word.dictionaryId = Int(item_array[10])!
                word.video = values.count == 12 ? values[11] : nil
            }
        } else {
            print("\(dictionaryFile) not exists")
        }
        print("1 Execution time: \(Date().timeIntervalSince(methodStart))")
        
        methodStart = Date()
        saveData()
        print("2 Execution time: \(Date().timeIntervalSince(methodStart))")
    }
    
    func saveData() {
        do {
            try managedObjectContext.save()
        } catch {
            print("*** managedObjectContext.save error: \(error.localizedDescription)\n***")
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
        return (str == "") ? nil : str
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
            wordsTableVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
            trendsVC.wordsTableVCRef = wordsTableVC
            favoritesTableVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
            favoritesTableVC.wordsTableVCRef = wordsTableVC
            moreVC.trendsVC = VControllers[1].topViewController as? TrendsTableVC
            moreVC.wordsVC = VControllers[0].topViewController as? WordsTableVC
        }
    }
}

