//
//  Word+CoreDataProperties.swift
//  SlangApp
//
//  Created by Kam Lotfull on 17.03.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word");
    }

    @NSManaged public var definition: String?
    @NSManaged public var examples: String?
    @NSManaged public var group: String?
    @NSManaged public var hashtags: String?
    @NSManaged public var name: String?
    @NSManaged public var story: String?
    @NSManaged public var type: String?
    @NSManaged public var groups: NSSet?

}

// MARK: Generated accessors for groups
extension Word {

    @objc(addGroupsObject:)
    @NSManaged public func addToGroups(_ value: Group)

    @objc(removeGroupsObject:)
    @NSManaged public func removeFromGroups(_ value: Group)

    @objc(addGroups:)
    @NSManaged public func addToGroups(_ values: NSSet)

    @objc(removeGroups:)
    @NSManaged public func removeFromGroups(_ values: NSSet)

}
