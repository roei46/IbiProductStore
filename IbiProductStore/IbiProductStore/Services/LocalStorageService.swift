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
