//
//  CoreDataStorageService.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData
import CryptoKit

final class CoreDataStorageService: LocalStorageServiceProtocol {
    
    // MARK: - Properties
    private let coreDataStack: CoreDataStack
    private let encryptionService = EncryptionService()
    
    // MARK: - Initialization
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    
    // MARK: - Favorites Management
    
    func loadFavorites() throws -> [Product] {
        let context = coreDataStack.context
        
        do {
            let cdProducts = try CDProduct.fetchFavorites(context: context)
            return cdProducts.map { encryptionService.decryptSensitiveFields($0) }
        } catch {
            throw CoreDataError("Failed to load favorites", underlyingError: error)
        }
    }
    
    // MARK: - Modified Products
    func saveModifiedProducts(_ products: [Product]) throws {
        let context = coreDataStack.context
        
        do {
            // First, reset all isLocallyModified flags
            let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
            request.predicate = NSPredicate(format: "isLocallyModified == YES")
            let existingModified = try context.fetch(request)
            existingModified.forEach { $0.isLocallyModified = false }
            
            // Then set the new modified products
            for product in products {
                if let existingProduct = try CDProduct.findByID(product.id, context: context) {
                    // Update existing product with new data
                    updateCDProduct(existingProduct, with: product)
                    existingProduct.isLocallyModified = true
                } else {
                    // Create new product (shouldn't happen for modifications)
                    let cdProduct = product.toCoreData(context: context)
                    encryptionService.encryptSensitiveFields(cdProduct, from: product)
                    cdProduct.isLocallyModified = true
                }
            }
            
            coreDataStack.save()
        } catch {
            throw CoreDataError("Failed to save modified products", underlyingError: error)
        }
    }
    
    func loadModifiedProducts() throws -> [Product] {
        let context = coreDataStack.context
        
        do {
            let cdProducts = try CDProduct.fetchModified(context: context)
            return cdProducts.map { encryptionService.decryptSensitiveFields($0) }
        } catch {
            throw CoreDataError("Failed to load modified products", underlyingError: error)
        }
    }
    
    // MARK: - Added Products
    func saveAddedProducts(_ products: [Product]) throws {
        let context = coreDataStack.context
        
        do {
            // Remove existing locally added products first
            let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
            request.predicate = NSPredicate(format: "isLocallyAdded == YES")
            let existingAdded = try context.fetch(request)
            existingAdded.forEach { context.delete($0) }
            
            // Add new locally added products
            for product in products {
                let cdProduct = product.toCoreData(context: context)
                encryptionService.encryptSensitiveFields(cdProduct, from: product)
                cdProduct.isLocallyAdded = true
            }
            
            coreDataStack.save()
        } catch {
            throw CoreDataError("Failed to save added products", underlyingError: error)
        }
    }
    
    func loadAddedProducts() throws -> [Product] {
        let context = coreDataStack.context
        
        do {
            let cdProducts = try CDProduct.fetchAdded(context: context)
            return cdProducts.map { encryptionService.decryptSensitiveFields($0) }
        } catch {
            throw CoreDataError("Failed to load added products", underlyingError: error)
        }
    }
    
    
    // MARK: - Clear Data
    func clearAllLocalData() throws {
        let context = coreDataStack.context
        
        do {
            // Delete locally added products with batch delete
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isLocallyAdded == YES")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try context.execute(deleteRequest)
            
            // Reset flags for server products with batch update
            let updateRequest = NSBatchUpdateRequest(entityName: "CDProduct")
            updateRequest.predicate = NSPredicate(format: "isLocallyAdded == NO")
            updateRequest.propertiesToUpdate = [
                "isFavorite": false,
                "isLocallyModified": false,
                "isLocallyDeleted": false
            ]
            try context.execute(updateRequest)
            
            coreDataStack.save()
        } catch {
            throw CoreDataError("Failed to clear local data", underlyingError: error)
        }
    }
    
    // MARK: - Favorites Helper Methods
    func isFavorite(_ product: Product) -> Bool {
        // Now we can just use the product's isFavorite property
        return product.isFavorite
    }
    
    func addToFavorites(_ product: Product) {
        let context = coreDataStack.context
        
        do {
            if let existingProduct = try CDProduct.findByID(product.id, context: context) {
                existingProduct.isFavorite = true
            } else {
                let cdProduct = product.toCoreData(context: context)
                encryptionService.encryptSensitiveFields(cdProduct, from: product)
                cdProduct.isFavorite = true
            }
            
            coreDataStack.save()
        } catch {
            print("Error adding to favorites: \(error)")
        }
    }
    
    func removeFromFavorites(_ product: Product) {
        let context = coreDataStack.context
        
        do {
            if let existingProduct = try CDProduct.findByID(product.id, context: context) {
                existingProduct.isFavorite = false
            }
            
            coreDataStack.save()
        } catch {
            print("Error removing from favorites: \(error)")
        }
    }
    
    func toggleFavorite(_ product: Product) {
        if product.isFavorite {
            addToFavorites(product)
        } else {
            removeFromFavorites(product)
        }
    }
    
    // MARK: - Helper Methods
    private func updateCDProduct(_ cdProduct: CDProduct, with product: Product) {
        // Update all properties - comprehensive to ensure Core Data sync
        cdProduct.title = product.title
        cdProduct.descriptionText = product.description
        cdProduct.category = product.category
        cdProduct.price = product.price
        cdProduct.discountPercentage = product.discountPercentage
        cdProduct.rating = product.rating
        cdProduct.stock = Int32(product.stock)
        cdProduct.tags = product.tags as NSArray
        cdProduct.brand = product.brand
        cdProduct.sku = product.sku
        cdProduct.weight = Int32(product.weight)
        cdProduct.warrantyInformation = product.warrantyInformation
        cdProduct.shippingInformation = product.shippingInformation
        cdProduct.availabilityStatus = product.availabilityStatus
        cdProduct.returnPolicy = product.returnPolicy
        cdProduct.minimumOrderQuantity = Int32(product.minimumOrderQuantity)
        cdProduct.images = product.images as NSArray
        cdProduct.thumbnail = product.thumbnail
        
        // Update dimensions
        if let dimensions = cdProduct.dimensions {
            dimensions.width = product.dimensions.width
            dimensions.height = product.dimensions.height
            dimensions.depth = product.dimensions.depth
        }
        
        // Update meta
        if let meta = cdProduct.meta {
            meta.createdAt = product.meta.createdAt
            meta.updatedAt = product.meta.updatedAt
            meta.barcode = product.meta.barcode
            meta.qrCode = product.meta.qrCode
        }
        
        // Update reviews (simple approach: delete and recreate)
        if let existingReviews = cdProduct.reviews?.allObjects as? [CDReview] {
            for review in existingReviews {
                coreDataStack.context.delete(review)
            }
        }
        
        for review in product.reviews {
            let cdReview = CDReview(context: coreDataStack.context)
            cdReview.rating = Int32(review.rating)
            cdReview.comment = review.comment
            cdReview.date = review.date
            cdReview.reviewerName = review.reviewerName
            cdReview.reviewerEmail = review.reviewerEmail
            cdReview.product = cdProduct
        }
    }
}
