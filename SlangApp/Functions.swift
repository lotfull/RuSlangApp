//
//  Functions.swift
//  SlangApp
//
//  Created by Kam Lotfull on 21.05.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import Foundation
import Dispatch

let applicationDocumentsDirectory: URL = {
    let urls = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    return urls[0]
}()

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    //print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}

extension String {
    func uppercaseFirst() -> String {
        if characters.count == 1 { return self.capitalized }
        if String(characters.prefix(2)).lowercased() != String(characters.prefix(2)) { return self }
        return String(characters.prefix(1)).capitalized + String(characters.dropFirst())
    }
}

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}

var needToUpdate = false

func shareWordFunc() {
    
}

var TranslitToHashtagsDict = ["#internet": "#Интернет"]
