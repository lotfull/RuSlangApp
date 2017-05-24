//
//  Word+CoreDataProperties.swift
//  SlangApp
//
//  Created by Kam Lotfull on 21.05.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var definition: String
    @NSManaged public var name: String
    @NSManaged public var group: String?
    @NSManaged public var type: String?
    @NSManaged public var examples: String?
    @NSManaged public var hashtags: String?
    @NSManaged public var origin: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var synonyms: String?

    func textViewString() -> String {
        let answer = "\(name)\n  \(definition)"
        
        return answer
    }
}
