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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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

    
    func parseCSV (contentsOfURL: URL, encoding: String.Encoding, error: NSErrorPointer) -> [(name: String, definition: String, type: String, group: String, examples: String, hashtags: String, story: String, synonims: String)]? {
        // Load the CSV file and parse it
        let delimiter = ","
        var items:[(name: String, definition: String, type: String, group: String,
        examples: String, hashtags: String, story: String, synonims: String)]?
        
        if let content = try? String(contentsOf: contentsOfURL, encoding: encoding) {
            items = []
            let lines: [String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
            for line in lines {
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.range(of: "\"") != nil {
                        var textToScan: String = line
                        var value: NSString?
                        var textScanner: Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpTo("\"", into: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpTo(delimiter, into: &value)
                            }
                            // Store the value into the values array
                            values.append(value! as String)
                            // Retrieve the unscanned remainder of the string
                            if textScanner.scanLocation < textScanner.string.characters.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    // Put the values into the tuple and add it to the items array
                    let item = (name: values[0], definition: values[1], type: values[2], group: values[3],
                                examples: values[4], hashtags: values[5], story: values[6], synonims: values[7])
                    items?.append(item)
                }
            }
        }
        return items
    }
    
    let test_dict = "test_dict"
    
    func returnNilIfNonNone(str: String) -> String? {
        if str == "NonNone" {
            return nil
        } else {
            return str
        }
    }
    
    func preloadData () {
        // Retrieve data from the source file
        if let contentsOfURL = Bundle.main.url(forResource: test_dict, withExtension: "csv") {
            
            // Remove all the menu items before preloading
            removeData()
            
            var error:NSError?
            if let items = parseCSV(contentsOfURL: contentsOfURL, encoding: String.Encoding.utf8, error: &error) {
                // Preload the menu items
                for item in items {
                    let word = NSEntityDescription.insertNewObject(forEntityName: "Word", into: managedObjectContext) as! Word
                    word.name = item.name
                    word.definition = returnNilIfNonNone(str: item.definition) == nil ? "" : item.definition
                    word.examples = returnNilIfNonNone(str: item.examples)
                    word.synonims = returnNilIfNonNone(str: item.synonims)
                    word.type = returnNilIfNonNone(str: item.type)
                    word.story = returnNilIfNonNone(str: item.story)
                    word.hashtags = returnNilIfNonNone(str: item.hashtags)
                    word.group = returnNilIfNonNone(str: item.group)
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
}

















