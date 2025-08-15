//
//  CDDimensions+CoreDataProperties.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData

extension CDDimensions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDimensions> {
        return NSFetchRequest<CDDimensions>(entityName: "CDDimensions")
    }

    @NSManaged public var depth: Double
    @NSManaged public var height: Double
    @NSManaged public var width: Double
    @NSManaged public var product: CDProduct?

}