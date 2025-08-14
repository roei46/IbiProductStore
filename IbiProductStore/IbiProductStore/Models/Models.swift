//
//  Models.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation

//struct Product: Codable, Equatable {
//    let id: Int
//    let title: String
//    let description: String
//    let price: Double
//    let brand: String
//    let thumbnail: String
//    let images: [String]
//    let category: String?
//    let rating: Double?
//    let stock: Int?
//    
//    static func == (lhs: Product, rhs: Product) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
//
//struct ProductResponse: Codable {
//    let products: [Product]
//    let total: Int
//    let skip: Int
//    let limit: Int
//}

// MARK: - User Model
struct User {
    let username: String
    let password: String
}
