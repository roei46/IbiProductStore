//
//  EncryptionService.swift
//  IbiProductStore
//
//  Created by Claude Code on 16/08/2025.
//

import Foundation
import CryptoKit

struct EncryptionService {
    
    // MARK: - Properties
    private let encryptionKey: SymmetricKey
    
    // MARK: - Initialization
    init() {
        self.encryptionKey = Self.getOrCreateEncryptionKey()
    }
    
    // MARK: - Encryption Key Management
    private static func getOrCreateEncryptionKey() -> SymmetricKey {
        let keyKey = "CoreDataEncryptionKey"
        
        if let existingKeyData = UserDefaults.standard.data(forKey: keyKey) {
            return SymmetricKey(data: existingKeyData)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            UserDefaults.standard.set(newKey.withUnsafeBytes { Data($0) }, forKey: keyKey)
            return newKey
        }
    }
    
    // MARK: - Product Encryption Methods
    func encryptSensitiveFields(_ cdProduct: CDProduct, from product: Product) {
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
        }
    }
    
    func decryptSensitiveFields(_ cdProduct: CDProduct) -> Product {
        var product = cdProduct.toProduct()
        
        if let idCipher = cdProduct.encryptedIDCipher,
           let idNonce = cdProduct.encryptedIDNonce,
           let skuCipher = cdProduct.encryptedSKUCipher,
           let skuNonce = cdProduct.encryptedSKUNonce {
            do {
                let decryptedID = try EncryptionHelper.decrypt(cipher: idCipher, nonceData: idNonce, using: encryptionKey)
                let decryptedSKU = try EncryptionHelper.decrypt(cipher: skuCipher, nonceData: skuNonce, using: encryptionKey)
                
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
            }
        }
        
        return product
    }
}