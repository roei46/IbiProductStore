//
//  CDMeta+CoreDataProperties.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData

extension CDMeta {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMeta> {
        return NSFetchRequest<CDMeta>(entityName: "CDMeta")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var qrCode: String?
    @NSManaged public var updatedAt: String?
    @NSManaged public var product: CDProduct?

}