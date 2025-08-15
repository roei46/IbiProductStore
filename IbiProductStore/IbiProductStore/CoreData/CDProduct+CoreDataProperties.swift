//
//  CDProduct+CoreDataProperties.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData

extension CDProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProduct> {
        return NSFetchRequest<CDProduct>(entityName: "CDProduct")
    }

    @NSManaged public var availabilityStatus: String?
    @NSManaged public var brand: String?
    @NSManaged public var category: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var discountPercentage: Double
    @NSManaged public var encryptedIDCipher: Data?
    @NSManaged public var encryptedIDNonce: Data?
    @NSManaged public var encryptedSKUCipher: Data?
    @NSManaged public var encryptedSKUNonce: Data?
    @NSManaged public var id: Int32
    @NSManaged public var images: NSArray?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isLocallyAdded: Bool
    @NSManaged public var isLocallyDeleted: Bool
    @NSManaged public var isLocallyModified: Bool
    @NSManaged public var minimumOrderQuantity: Int32
    @NSManaged public var price: Double
    @NSManaged public var rating: Double
    @NSManaged public var returnPolicy: String?
    @NSManaged public var shippingInformation: String?
    @NSManaged public var sku: String?
    @NSManaged public var stock: Int32
    @NSManaged public var tags: NSArray?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var warrantyInformation: String?
    @NSManaged public var weight: Int32
    @NSManaged public var dimensions: CDDimensions?
    @NSManaged public var meta: CDMeta?
    @NSManaged public var reviews: NSSet?

}

// MARK: Generated accessors for reviews
extension CDProduct {

    @objc(addReviewsObject:)
    @NSManaged public func addToReviews(_ value: CDReview)

    @objc(removeReviewsObject:)
    @NSManaged public func removeFromReviews(_ value: CDReview)

    @objc(addReviews:)
    @NSManaged public func addToReviews(_ values: NSSet)

    @objc(removeReviews:)
    @NSManaged public func removeFromReviews(_ values: NSSet)

}