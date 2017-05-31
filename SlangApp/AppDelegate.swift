//
//  AppDelegate.swift
//  SlangApp
//
//  Created by Kam Lotfull on 24.01.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window?.tintColor = UIColor.purple
        let defaults = UserDefaults.standard
        //defaults.set(false, forKey: "isPreloaded")
        let isPreloaded = defaults.bool(forKey: isPreloadedKey)
        if !isPreloaded {
            preloadDataFromCSVFile()
            defaults.set(true, forKey: isPreloadedKey)
        }
        if let tabBarVC = window!.rootViewController as? UITabBarController,
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
        listenForFatalCoreDataNotifications()
        return true
    }

    // MARK: - Core Data stack
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDefinition, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - FatalCoreDataNotifications
    
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(
            forName: MyManagedObjectContextSaveDidFailNotification,
            object: nil,
            queue: OperationQueue.main) { notification in
                let alert = UIAlertController(
                    title: "Internal error",
                    message: "There was fatal error. Please contact us in app contact form.\nPress OK to terminate app. We will solve this problem asap",
                    preferredStyle: .alert)
                let fatalErrorOKAction = UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: { (_) in
                        let exception = NSException(
                            name: NSExceptionName.internalInconsistencyException,
                            reason: "Fatal Core Data error",
                            userInfo: nil)
                        exception.raise()
                }
                )
                alert.addAction(fatalErrorOKAction)
                self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
        }
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if rootViewController.presentedViewController != nil {
            return rootViewController.presentedViewController!
        } else {
            return rootViewController
        }
    }
    
    // MARK: - PRELOAD FROM CSV FUNCS
    
    func returnNilIfNonNone(str: String) -> String? {
        if str == "NonNone" {
            return nil
        } else {
            return str
        }
    }
    
    func preloadDataFromCSVFile () {
        removeData()
        if let contentsOfURL = Bundle.main.url(forResource: fullDict, withExtension: "csv") {
            if let content = try? String(contentsOf: contentsOfURL, encoding: String.Encoding.utf8) {
                let items_arrays = content.csvRows(firstRowIgnored: true)
                for item_array in items_arrays {
                    let word = NSEntityDescription.insertNewObject(forEntityName: "Word", into: managedObjectContext) as! Word
                    word.name = item_array[0]
                    word.definition = (returnNilIfNonNone(str: item_array[1]) == nil ? "No definition" : item_array[1])
                    word.type = returnNilIfNonNone(str: item_array[2])
                    word.group = returnNilIfNonNone(str: item_array[3])
                    word.examples = returnNilIfNonNone(str: item_array[4])
                    word.hashtags = returnNilIfNonNone(str: item_array[5])
                    word.origin = returnNilIfNonNone(str: item_array[6])
                    word.synonyms = returnNilIfNonNone(str: item_array[7])
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
    
    func deleteObject(withID objectID: NSManagedObjectID) {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "attendance = \(objectID)")// Predicate.init(format: "profileID==\(withID)")
        if let result = try? managedObjectContext.fetch(fetchRequest) {
            for object in result {
                managedObjectContext.delete(object)
            }
        }
    }
    
    func println(_ s: String) {
        let path = "/Users/lotfull/Desktop/xcode/SlangApp/SlangApp/output.txt"
        var dump = ""
        if FileManager.default.fileExists(atPath: path) {
            dump =  try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        }
        do {
            // Write to the file
            try  "\(dump)\n\(s)".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to log file: \(path), Error: " + error.localizedDescription)
        }
    }
    
    let fullDict = "fullDict"
    let isPreloadedKey = "isPreloaded"
    
}

















