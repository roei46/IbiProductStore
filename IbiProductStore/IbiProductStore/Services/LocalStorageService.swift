//
//  LocalStorageService.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CryptoKit

protocol LocalStorageServiceProtocol {
    func loadFavorites() throws -> [Product]
    func saveModifiedProducts(_ products: [Product]) throws
    func loadModifiedProducts() throws -> [Product]
    func saveAddedProducts(_ products: [Product]) throws
    func loadAddedProducts() throws -> [Product]
    func clearAllLocalData() throws
    
    // Favorites helper methods
    func isFavorite(_ product: Product) -> Bool
    func addToFavorites(_ product: Product)
    func removeFromFavorites(_ product: Product)
    func toggleFavorite(_ product: Product)
}
