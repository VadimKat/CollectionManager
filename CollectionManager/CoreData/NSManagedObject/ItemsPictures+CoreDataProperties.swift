//
//  ItemsPictures+CoreDataProperties.swift
//  CollectionManager
//
//  Created by Vadim Katenin on 14.04.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//
//

import Foundation
import CoreData


extension ItemsPictures {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemsPictures> {
        return NSFetchRequest<ItemsPictures>(entityName: "ItemsPictures")
    }

    @NSManaged public var photo: Data?
    @NSManaged public var toCollection: Collection?

}
