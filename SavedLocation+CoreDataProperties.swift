//
//  SavedLocation+CoreDataProperties.swift
//  Locations
//
//  Created by Sujit Molleti on 7/12/20.
//  Copyright © 2020 Sujit Molleti. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedLocation> {
        return NSFetchRequest<SavedLocation>(entityName: "SavedLocation")
    }

    @NSManaged public var coordinate: namedCoordinate?

}
