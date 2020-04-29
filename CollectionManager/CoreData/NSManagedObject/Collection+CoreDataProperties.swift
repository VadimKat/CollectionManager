//
//  Collection+CoreDataProperties.swift
//  CollectionManager
//
//  Created by Vadim Katenin on 14.04.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//
//

import Foundation
import CoreData


extension Collection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Collection> {
        return NSFetchRequest<Collection>(entityName: "Collection")
    }

    @NSManaged public var name: String?
    @NSManaged public var pictureThumbnail: Data?
    @NSManaged public var date: Date?
    @NSManaged public var category: Int16
    @NSManaged public var pictureLink: ItemsPictures?

}
