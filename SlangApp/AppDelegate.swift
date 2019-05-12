//
//  AppDelegate.swift
//  SlangApp
//
//  Created by Kam Lotfull on 24.01.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit
import CoreData
import Firebase

struct AppFontName {
    static let regular = "HelveticaNeue"//"CourierNewPSMT"
    static let bold = "HelveticaNeue-Bold"//"CourierNewPS-BoldMT"
    static let italic = "HelveticaNeue-Italic"//"CourierNewPS-ItalicMT"
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
            if let fontAttribute = convertFromUIFontDescriptorAttributeNameDictionary(fontDescriptor.fontAttributes)["NSCTFontUIUsageAttribute"] as? String {
                var fontName = ""
                switch fontAttribute {
                case "CTFontRegularUsage":
                    fontName = AppFontName.regular
                case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                    fontName = AppFontName.bold
                case "CTFontObliqueUsage":
                    fontName = AppFontName.italic
                default:
                    fontName = AppFontName.regular
                }
                self.init(name: fontName, size: fontDescriptor.pointSize)!
            } else {
                self.init(myCoder: aDecoder)
            }
        } else {
            self.init(myCoder: aDecoder)
        }
    }
    
    class func overrideInitialize() {
        if self == UIFont.self {
            let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
            method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)
            
            let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
            method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)
            
            let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:)))
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:)))
            method_exchangeImplementations(italicSystemFontMethod!, myItalicSystemFontMethod!)
            
            let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
            method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let dictionaries = ["Словарь сленга", "Teenslang.su", "Vsekidki.ru", "Модные-слова.рф"]
    let appColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
    
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }
    
    var words: [Word]!
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        window?.tintColor = appColor
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
    
    func saveContext() {
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
    
    func println(_ s: String) {
        let path = "/Users/lotfull/Desktop/xcode/SlangApp/SlangApp/output.txt"
        var dump = ""
        if FileManager.default.fileExists(atPath: path) {
            dump = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        }
        do {
            // Write to the file
            try "\(dump)\n\(s)".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to log file: \(path), Error: " + error.localizedDescription)
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIFontDescriptorAttributeNameDictionary(_ input: [UIFontDescriptor.AttributeName: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
