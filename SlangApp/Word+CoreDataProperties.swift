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
    @NSManaged public var synonyms: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var id: Int
    
    func textViewString() -> String {
        var answer = "\(name)\n\(definition)"
        if group != nil {
            answer += "\nгруппа: \(group!)"
        }
        if type != nil {
            answer += "\nтип: \(type!)"
        }
        if hashtags != nil {
            answer += "\nтеги: \(hashtags!)"
        }
        if examples != nil {
            answer += "\nпримеры: \(examples!)"
        }
        if origin != nil {
            answer += "\nпроисх.: \(origin!)"
        }
        if synonyms != nil {
            answer += "\nсин.: \(synonyms!)"
        }
        return answer
    }
    
}
