//
//  Product+CoreData.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData
import CryptoKit

// MARK: - Product to Core Data Conversion
extension Product {
    
    /// Convert API Product to Core Data CDProduct
    func toCoreData(context: NSManagedObjectContext) -> CDProduct {
        let cdProduct = CDProduct(context: context)
        
        // Basic properties
        cdProduct.id = Int32(self.id)
        cdProduct.title = self.title
        cdProduct.descriptionText = self.description
        cdProduct.category = self.category
        cdProduct.price = self.price
        cdProduct.discountPercentage = self.discountPercentage
        cdProduct.rating = self.rating
        cdProduct.stock = Int32(self.stock)
        cdProduct.tags = self.tags as NSArray
        cdProduct.brand = self.brand
        cdProduct.sku = self.sku
        cdProduct.weight = Int32(self.weight)
        
        // Note: Encryption will be handled by CoreDataStorageService
        // Store plain values here, service will encrypt before saving
        cdProduct.id = Int32(self.id)
        cdProduct.sku = self.sku
        cdProduct.warrantyInformation = self.warrantyInformation
        cdProduct.shippingInformation = self.shippingInformation
        cdProduct.availabilityStatus = self.availabilityStatus
        cdProduct.returnPolicy = self.returnPolicy
        cdProduct.minimumOrderQuantity = Int32(self.minimumOrderQuantity)
        cdProduct.images = self.images as NSArray
        cdProduct.thumbnail = self.thumbnail
        
        // Dimensions
        let cdDimensions = CDDimensions(context: context)
        cdDimensions.width = self.dimensions.width
        cdDimensions.height = self.dimensions.height
        cdDimensions.depth = self.dimensions.depth
        cdProduct.dimensions = cdDimensions
        
        // Meta
        let cdMeta = CDMeta(context: context)
        cdMeta.createdAt = self.meta.createdAt
        cdMeta.updatedAt = self.meta.updatedAt
        cdMeta.barcode = self.meta.barcode
        cdMeta.qrCode = self.meta.qrCode
        cdProduct.meta = cdMeta
        
        // Reviews
        for review in self.reviews {
            let cdReview = CDReview(context: context)
            cdReview.rating = Int32(review.rating)
            cdReview.comment = review.comment
            cdReview.date = review.date
            cdReview.reviewerName = review.reviewerName
            cdReview.reviewerEmail = review.reviewerEmail
            cdReview.product = cdProduct
        }
        
        // Local tracking flags (default to false for API products)
        cdProduct.isFavorite = false
        cdProduct.isLocallyAdded = false
        cdProduct.isLocallyModified = false
        cdProduct.isLocallyDeleted = false
        
        return cdProduct
    }
}

// MARK: - Core Data to Product Conversion
extension CDProduct {
    
    /// Convert Core Data CDProduct to API Product
    func toProduct() -> Product {
        let dimensions = Dimensions(
            width: self.dimensions?.width ?? 0,
            height: self.dimensions?.height ?? 0,
            depth: self.dimensions?.depth ?? 0
        )
        
        let meta = Meta(
            createdAt: self.meta?.createdAt ?? "",
            updatedAt: self.meta?.updatedAt ?? "",
            barcode: self.meta?.barcode ?? "",
            qrCode: self.meta?.qrCode ?? ""
        )
        
        let reviews = (self.reviews?.allObjects as? [CDReview])?.map { cdReview in
            Review(
                rating: Int(cdReview.rating),
                comment: cdReview.comment ?? "",
                date: cdReview.date ?? "",
                reviewerName: cdReview.reviewerName ?? "",
                reviewerEmail: cdReview.reviewerEmail ?? ""
            )
        } ?? []
        
        // Note: Decryption will be handled by CoreDataStorageService
        // This method assumes decryption already happened
        var product = Product(
            id: Int(self.id),
            title: self.title ?? "",
            description: self.descriptionText ?? "",
            category: self.category ?? "",
            price: self.price,
            discountPercentage: self.discountPercentage,
            rating: self.rating,
            stock: Int(self.stock),
            tags: (self.tags as? [String]) ?? [],
            brand: self.brand,
            sku: self.sku ?? "",
            weight: Int(self.weight),
            dimensions: dimensions,
            warrantyInformation: self.warrantyInformation ?? "",
            shippingInformation: self.shippingInformation ?? "",
            availabilityStatus: self.availabilityStatus ?? "",
            reviews: reviews,
            returnPolicy: self.returnPolicy ?? "",
            minimumOrderQuantity: Int(self.minimumOrderQuantity),
            meta: meta,
            images: (self.images as? [String]) ?? [],
            thumbnail: self.thumbnail ?? ""
        )
        product.isFavorite = self.isFavorite
        return product
    }
}

// MARK: - Core Data Fetch Helpers
extension CDProduct {
    
    /// Fetch all products
    static func fetchAll(context: NSManagedObjectContext) throws -> [CDProduct] {
        let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return try context.fetch(request)
    }
    
    /// Fetch favorites
    static func fetchFavorites(context: NSManagedObjectContext) throws -> [CDProduct] {
        let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES AND isLocallyDeleted == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return try context.fetch(request)
    }
    
    /// Fetch locally modified products
    static func fetchModified(context: NSManagedObjectContext) throws -> [CDProduct] {
        let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "isLocallyModified == YES AND isLocallyDeleted == NO")
        return try context.fetch(request)
    }
    
    /// Fetch locally added products
    static func fetchAdded(context: NSManagedObjectContext) throws -> [CDProduct] {
        let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "isLocallyAdded == YES AND isLocallyDeleted == NO")
        return try context.fetch(request)
    }
    
    /// Fetch locally deleted product IDs
    static func fetchDeletedIds(context: NSManagedObjectContext) throws -> [Int] {
        let request = NSFetchRequest<NSDictionary>(entityName: "CDProduct")
        request.predicate = NSPredicate(format: "isLocallyDeleted == YES")
        request.propertiesToFetch = ["id"]
        request.resultType = .dictionaryResultType
        
        let results = try context.fetch(request)
        return results.compactMap { dict in
            if let id = dict["id"] as? Int32 {
                return Int(id)
            }
            return nil
        }
    }
    
    /// Find product by ID
    static func findByID(_ id: Int, context: NSManagedObjectContext) throws -> CDProduct? {
        let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
