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
        if let initialVC = window!.rootViewController as? AppLaunchingInitialVC {
            initialVC.managedObjectContext = managedObjectContext
        } else {
            print("Something went wrong with managedObjectContext assignment")
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
                })
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
    

    
}

















