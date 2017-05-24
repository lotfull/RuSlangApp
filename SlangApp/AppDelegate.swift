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
        
        let defaults = UserDefaults.standard
        //defaults.set(false, forKey: "isPreloaded")
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        if let navigationVC = window!.rootViewController as? UINavigationController,
            let wordsTableVC = navigationVC.topViewController as? WordsTableVC {
                wordsTableVC.managedObjectContext = managedObjectContext
        } else {
            fatalError("not correct window!.rootViewController as? UINavigationController unwrapping")
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
    
    let test_dict = "test_dict"
    
    func returnNilIfNonNone(str: String) -> String? {
        if str == "NonNone" {
            return nil
        } else {
            return str
        }
    }
    
    let dict = "dict"
    
    func preloadData () {
        removeData()
        var i = 0;
        while i <= 31 {
            if let contentsOfURL = Bundle.main.url(forResource: dict + "\(i)", withExtension: "csv") {
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
                        word.story = returnNilIfNonNone(str: item_array[6])
                        word.synonyms = returnNilIfNonNone(str: item_array[7])
                        do {
                            try managedObjectContext.save()
                        } catch {
                            print("**********insert error: \(error.localizedDescription)\n********")
                        }
                    }
                }
            }
            i += 1
            print("Парсинг \(i + 1) из \(32)")
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
}

















