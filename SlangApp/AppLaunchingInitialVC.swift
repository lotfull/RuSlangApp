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
        
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //activityIndicator.startAnimating()
        
        // Asynchronous, with quality of class
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isPreloaded")
            let isPreloaded = defaults.bool(forKey: appDelegate.isPreloadedKey)
            if !isPreloaded {
                appDelegate.preloadDataFromCSVFile()
                defaults.set(true, forKey: appDelegate.isPreloadedKey)
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.showMainVCID, sender: nil)
                //self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .utility).async {
            
            let kNumberOfIterations = 81
            var iIndicator = self.view.viewWithTag(101) as! UIActivityIndicatorView
            for i in 1 ... kNumberOfIterations {
                
                usleep(50 * 1000)
                // do something time consuming here
                
                DispatchQueue.main.async {
                    // now update UI on main thread
                    iIndicator.color = UIColor.purple
                    iIndicator.stopAnimating()
                    iIndicator = self.view.viewWithTag(100 + i) as! UIActivityIndicatorView
                    iIndicator.startAnimating()
                    self.progressView.setProgress(Float(i) / Float(kNumberOfIterations), animated: true)
                }
            }
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
    
}
