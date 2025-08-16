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
    private let encryptionKey = SymmetricKey(size: .bits256)
    
    // MARK: - Initialization
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Favorites Management
    func saveFavorites(_ products: [Product]) {
        // Core Data approach: Update existing products or create new ones
        let context = coreDataStack.context
        
        do {
            for product in products {
                if let existingProduct = try CDProduct.findByID(product.id, context: context) {
                    existingProduct.isFavorite = true
                } else {
                    let cdProduct = product.toCoreData(context: context)
                    encryptSensitiveFields(cdProduct, from: product)
                    cdProduct.isFavorite = true
                }
            }
            
            coreDataStack.save()
        } catch {
            print("Error saving favorites: \(error)")
        }
    }
    
    func loadFavorites() -> [Product] {
        let context = coreDataStack.context
        
        do {
            let cdProducts = try CDProduct.fetchFavorites(context: context)
            return cdProducts.map { decryptSensitiveFields($0) }
        } catch {
            print("Error loading favorites: \(error)")
            return []
        }
    }
    
    // MARK: - Modified Products
    func saveModifiedProducts(_ products: [Product]) {
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
                    encryptSensitiveFields(cdProduct, from: product)
                    cdProduct.isLocallyModified = true
                }
            }
            
            coreDataStack.save()
        } catch {
            print("Error saving modified products: \(error)")
        }
    }
    
    func loadModifiedProducts() -> [Product] {
        let context = coreDataStack.context
        
        do {
            let cdProducts = try CDProduct.fetchModified(context: context)
            return cdProducts.map { decryptSensitiveFields($0) }
        } catch {
            print("Error loading modified products: \(error)")
            return []
        }
    }
    
    // MARK: - Added Products
    func saveAddedProducts(_ products: [Product]) {
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
                encryptSensitiveFields(cdProduct, from: product)
                cdProduct.isLocallyAdded = true
            }
            
            coreDataStack.save()
        } catch {
            print("Error saving added products: \(error)")
        }
    }
    
    func loadAddedProducts() -> [Product] {
        let context = coreDataStack.context
        
        do {
            let cdProducts = try CDProduct.fetchAdded(context: context)
            return cdProducts.map { decryptSensitiveFields($0) }
        } catch {
            print("Error loading added products: \(error)")
            return []
        }
    }
    
    // MARK: - Deleted Product IDs
    func saveDeletedProductIds(_ ids: [Int]) {
        let context = coreDataStack.context
        
        do {
            for id in ids {
                if let existingProduct = try CDProduct.findByID(id, context: context) {
                    existingProduct.isLocallyDeleted = true
                } else {
                    // Create a minimal product record just to track deletion
                    let cdProduct = CDProduct(context: context)
                    cdProduct.id = Int32(id)
                    cdProduct.isLocallyDeleted = true
                    cdProduct.title = "Deleted Product"
                }
            }
            
            coreDataStack.save()
        } catch {
            print("Error saving deleted product IDs: \(error)")
        }
    }
    
    func loadDeletedProductIds() -> [Int] {
        let context = coreDataStack.context
        
        do {
            return try CDProduct.fetchDeletedIds(context: context)
        } catch {
            print("Error loading deleted product IDs: \(error)")
            return []
        }
    }
    
    // MARK: - Clear Data
    func clearAllLocalData() {
        let context = coreDataStack.context
        
        do {
            // Reset all local flags instead of deleting everything
            let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
            let allProducts = try context.fetch(request)
            
            for product in allProducts {
                if product.isLocallyAdded {
                    // Delete locally added products completely
                    context.delete(product)
                } else {
                    // Reset flags for server products
                    product.isFavorite = false
                    product.isLocallyModified = false
                    product.isLocallyDeleted = false
                }
            }
            
            coreDataStack.save()
        } catch {
            print("Error clearing local data: \(error)")
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
                encryptSensitiveFields(cdProduct, from: product)
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
        // Product.isFavorite already reflects the desired state
        if product.isFavorite {
            addToFavorites(product)
        } else {
            removeFromFavorites(product)
        }
    }
    
    // MARK: - Helper Methods
    private func updateCDProduct(_ cdProduct: CDProduct, with product: Product) {
        // Update all properties
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
    
    // MARK: - Encryption Helper Methods
    private func encryptSensitiveFields(_ cdProduct: CDProduct, from product: Product) {
        // Skip if already encrypted
        if cdProduct.encryptedIDCipher != nil && cdProduct.encryptedSKUCipher != nil {
            return
        }
        
        do {
            // Encrypt product ID
            let productIdString = String(product.id)
            guard !productIdString.isEmpty else {
                print("⚠️ Product ID is empty, skipping encryption")
                return
            }
            
            let (idCipher, idNonce) = try EncryptionHelper.encrypt(productIdString, using: encryptionKey)
            cdProduct.encryptedIDCipher = idCipher
            cdProduct.encryptedIDNonce = idNonce
            
            // Encrypt SKU
            let skuValue = product.sku
            guard !skuValue.isEmpty else {
                print("⚠️ SKU value is empty, skipping encryption")
                return
            }
            
            let (skuCipher, skuNonce) = try EncryptionHelper.encrypt(skuValue, using: encryptionKey)
            cdProduct.encryptedSKUCipher = skuCipher
            cdProduct.encryptedSKUNonce = skuNonce
            
        } catch {
            print("❌ Encryption failed: \(error)")
            // Don't rethrow - allow the save to continue without encryption
        }
    }
    
    private func decryptSensitiveFields(_ cdProduct: CDProduct) -> Product {
        var product = cdProduct.toProduct() // Start with base product
        
        // Try to decrypt if encrypted fields exist
        if let idCipher = cdProduct.encryptedIDCipher,
           let idNonce = cdProduct.encryptedIDNonce,
           let skuCipher = cdProduct.encryptedSKUCipher,
           let skuNonce = cdProduct.encryptedSKUNonce {
            do {
                let decryptedID = try EncryptionHelper.decrypt(cipher: idCipher, nonceData: idNonce, using: encryptionKey)
                let decryptedSKU = try EncryptionHelper.decrypt(cipher: skuCipher, nonceData: skuNonce, using: encryptionKey)
                
                // Create new product with decrypted values
                var newProduct = Product(
                    id: Int(decryptedID) ?? product.id,
                    title: product.title,
                    description: product.description,
                    category: product.category,
                    price: product.price,
                    discountPercentage: product.discountPercentage,
                    rating: product.rating,
                    stock: product.stock,
                    tags: product.tags,
                    brand: product.brand,
                    sku: decryptedSKU,
                    weight: product.weight,
                    dimensions: product.dimensions,
                    warrantyInformation: product.warrantyInformation,
                    shippingInformation: product.shippingInformation,
                    availabilityStatus: product.availabilityStatus,
                    reviews: product.reviews,
                    returnPolicy: product.returnPolicy,
                    minimumOrderQuantity: product.minimumOrderQuantity,
                    meta: product.meta,
                    images: product.images,
                    thumbnail: product.thumbnail
                )
                newProduct.isFavorite = product.isFavorite
                product = newProduct
            } catch {
                print("Decryption failed: \(error)")
                // Clear corrupted encryption data so future saves work properly
                cdProduct.encryptedIDCipher = nil
                cdProduct.encryptedIDNonce = nil
                cdProduct.encryptedSKUCipher = nil
                cdProduct.encryptedSKUNonce = nil
                // Save the cleared encryption state
                try? coreDataStack.context.save()
                // Return product with plain values (already loaded)
            }
        }
        
        return product
    }
}
