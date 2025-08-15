//
//  CDReview+CoreDataProperties.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData

extension CDReview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDReview> {
        return NSFetchRequest<CDReview>(entityName: "CDReview")
    }

    @NSManaged public var comment: String?
    @NSManaged public var date: String?
    @NSManaged public var rating: Int32
    @NSManaged public var reviewerEmail: String?
    @NSManaged public var reviewerName: String?
    @NSManaged public var product: CDProduct?

}