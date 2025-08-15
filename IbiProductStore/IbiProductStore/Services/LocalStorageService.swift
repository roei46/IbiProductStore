//
//  LocalStorageService.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CryptoKit

protocol LocalStorageServiceProtocol {
    func saveFavorites(_ products: [Product])
    func loadFavorites() -> [Product]
    func saveModifiedProducts(_ products: [Product])
    func loadModifiedProducts() -> [Product]
    func saveAddedProducts(_ products: [Product])
    func loadAddedProducts() -> [Product]
    func saveDeletedProductIds(_ ids: [Int])
    func loadDeletedProductIds() -> [Int]
    func clearAllLocalData()
    
    // Favorites helper methods
    func isFavorite(_ product: Product) -> Bool
    func addToFavorites(_ product: Product)
    func removeFromFavorites(_ product: Product)
    func toggleFavorite(_ product: Product)
}

//final class LocalStorageService: LocalStorageServiceProtocol {
//    
//    // MARK: - Properties
//    static let shared = LocalStorageService()
//    
//    private let userDefaults = UserDefaults.standard
//    private let encryptionKey: SymmetricKey
//    
//    // MARK: - Keys
//    private enum StorageKeys {
//        static let favorites = "encrypted_favorites"
//        static let modifiedProducts = "encrypted_modified_products"
//        static let addedProducts = "encrypted_added_products"
//        static let deletedProductIds = "encrypted_deleted_product_ids"
//        static let encryptionKeyData = "storage_encryption_key"
//    }
//    
//    // MARK: - Initialization
//    private init() {
//        // Generate or load encryption key
//        if let keyData = userDefaults.data(forKey: StorageKeys.encryptionKeyData) {
//            self.encryptionKey = SymmetricKey(data: keyData)
//        } else {
//            self.encryptionKey = SymmetricKey(size: .bits256)
//            userDefaults.set(encryptionKey.withUnsafeBytes { Data($0) }, forKey: StorageKeys.encryptionKeyData)
//        }
//    }
//    
//    // MARK: - Favorites
//    func saveFavorites(_ products: [Product]) {
//        saveEncrypted(products, key: StorageKeys.favorites)
//    }
//    
//    func loadFavorites() -> [Product] {
//        return loadEncrypted([Product].self, key: StorageKeys.favorites) ?? []
//    }
//    
//    // MARK: - Modified Products
//    func saveModifiedProducts(_ products: [Product]) {
//        saveEncrypted(products, key: StorageKeys.modifiedProducts)
//    }
//    
//    func loadModifiedProducts() -> [Product] {
//        return loadEncrypted([Product].self, key: StorageKeys.modifiedProducts) ?? []
//    }
//    
//    // MARK: - Added Products
//    func saveAddedProducts(_ products: [Product]) {
//        saveEncrypted(products, key: StorageKeys.addedProducts)
//    }
//    
//    func loadAddedProducts() -> [Product] {
//        return loadEncrypted([Product].self, key: StorageKeys.addedProducts) ?? []
//    }
//    
//    // MARK: - Deleted Product IDs
//    func saveDeletedProductIds(_ ids: [Int]) {
//        saveEncrypted(ids, key: StorageKeys.deletedProductIds)
//    }
//    
//    func loadDeletedProductIds() -> [Int] {
//        return loadEncrypted([Int].self, key: StorageKeys.deletedProductIds) ?? []
//    }
//    
//    // MARK: - Clear Data
//    func clearAllLocalData() {
//        userDefaults.removeObject(forKey: StorageKeys.favorites)
//        userDefaults.removeObject(forKey: StorageKeys.modifiedProducts)
//        userDefaults.removeObject(forKey: StorageKeys.addedProducts)
//        userDefaults.removeObject(forKey: StorageKeys.deletedProductIds)
//    }
//    
//    // MARK: - Private Encryption Methods
//    private func saveEncrypted<T: Codable>(_ object: T, key: String) {
//        do {
//            let jsonData = try JSONEncoder().encode(object)
//            let encryptedData = try encrypt(data: jsonData)
//            userDefaults.set(encryptedData, forKey: key)
//        } catch {
//            print("Failed to save encrypted data for key \(key): \(error)")
//        }
//    }
//    
//    private func loadEncrypted<T: Codable>(_ type: T.Type, key: String) -> T? {
//        guard let encryptedData = userDefaults.data(forKey: key) else { return nil }
//        
//        do {
//            let decryptedData = try decrypt(data: encryptedData)
//            return try JSONDecoder().decode(type, from: decryptedData)
//        } catch {
//            print("Failed to load encrypted data for key \(key): \(error)")
//            return nil
//        }
//    }
//    
//    private func encrypt(data: Data) throws -> Data {
//        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
//        return sealedBox.combined!
//    }
//    
//    private func decrypt(data: Data) throws -> Data {
//        let sealedBox = try AES.GCM.SealedBox(combined: data)
//        return try AES.GCM.open(sealedBox, using: encryptionKey)
//    }
//}
//
//// MARK: - Favorites Helper
//extension LocalStorageService {
//    func isFavorite(_ product: Product) -> Bool {
//        let favorites = loadFavorites()
//        return favorites.contains { $0.id == product.id }
//    }
//    
//    func addToFavorites(_ product: Product) {
//        var favorites = loadFavorites()
//        if !favorites.contains(where: { $0.id == product.id }) {
//            favorites.append(product)
//            saveFavorites(favorites)
//        }
//    }
//    
//    func removeFromFavorites(_ product: Product) {
//        var favorites = loadFavorites()
//        favorites.removeAll { $0.id == product.id }
//        saveFavorites(favorites)
//    }
//    
//    func toggleFavorite(_ product: Product) {
//        if isFavorite(product) {
//            removeFromFavorites(product)
//        } else {
//            addToFavorites(product)
//        }
//    }
//}
