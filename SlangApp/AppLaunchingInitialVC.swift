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
        for appwordsFile in [teenslang, vsekidki] {
            print("\(appwordsFile) Nigga!")
            if let contentsOfURL = Bundle.main.url(forResource: appwordsFile, withExtension: "csv") {
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
    
    var managedObjectContext: NSManagedObjectContext!
    var tabBarControl: UITabBarController!
    let showMainVCID = "ShowMainVC"
    let isPreloadedKey = "isPreloaded"
    let teenslang = "teenslang_appwords"
    let vsekidki = "vsekidki_appwords"
    let wordsVersion = "1"
}
