//
//  Group+CoreDataProperties.swift
//  SlangApp
//
//  Created by Kam Lotfull on 17.03.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group");
    }

    @NSManaged public var groupName: String?
    @NSManaged public var words: NSSet?

}

// MARK: Generated accessors for words
extension Group {

    @objc(addWordsObject:)
    @NSManaged public func addToWords(_ value: Word)

    @objc(removeWordsObject:)
    @NSManaged public func removeFromWords(_ value: Word)

    @objc(addWords:)
    @NSManaged public func addToWords(_ values: NSSet)

    @objc(removeWords:)
    @NSManaged public func removeFromWords(_ values: NSSet)

}
