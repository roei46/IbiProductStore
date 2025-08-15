//
//  Product.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation

// MARK: - ProductResponse
struct ProductResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Product
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let tags: [String]
    let brand: String?
    let sku: String
    let weight: Int
    let dimensions: Dimensions
    let warrantyInformation: String
    let shippingInformation: String
    let availabilityStatus: String
    let reviews: [Review]
    let returnPolicy: String
    let minimumOrderQuantity: Int
    let meta: Meta
    let images: [String]
    let thumbnail: String
    
    // Not part of API response, handled locally
    var isFavorite: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, category, price, discountPercentage, rating, stock, tags, brand, sku, weight, dimensions, warrantyInformation, shippingInformation, availabilityStatus, reviews, returnPolicy, minimumOrderQuantity, meta, images, thumbnail
    }
}

// MARK: - Dimensions
struct Dimensions: Codable {
    let width: Double
    let height: Double
    let depth: Double
}

// MARK: - Review
struct Review: Codable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String
}

// MARK: - Meta
struct Meta: Codable {
    let createdAt: String
    let updatedAt: String
    let barcode: String
    let qrCode: String
}

// MARK: - Product Extensions
extension Product {
    var discountedPrice: Double {
        return price * (1 - discountPercentage / 100)
    }
    
    var isInStock: Bool {
        return availabilityStatus == "In Stock"
    }
    
    var isLowStock: Bool {
        return availabilityStatus == "Low Stock"
    }
    
    var averageRating: Double {
        guard !reviews.isEmpty && reviews.count > 0 else { return rating }
        let totalRating = reviews.reduce(0) { $0 + $1.rating }
        let average = Double(totalRating) / Double(reviews.count)
        return average.isFinite ? average : rating
    }
    
    var formattedPrice: String {
        guard price.isFinite && !price.isNaN else {
            return "$0.00"
        }
        return String(format: "$%.2f", price)
    }
    
    var formattedDiscountedPrice: String {
        guard discountedPrice.isFinite && !discountedPrice.isNaN else {
            return "$0.00"
        }
        return String(format: "$%.2f", discountedPrice)
    }
}