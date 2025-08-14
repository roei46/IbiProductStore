//
//  ProductCellViewModel.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import UIKit
import Combine

class ProductCellViewModel: ObservableObject {
    
    // MARK: - Properties
    private let product: Product
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    @Published var thumbnailImage: UIImage?
    @Published var isImageLoading: Bool = false
    
    // MARK: - Computed Properties
    var title: String {
        return product.title
    }
    
    var brand: String {
        return product.brand ?? "No Brand"
    }
    
    var description: String {
        return product.description
    }
    
    var price: String {
        return product.formattedPrice
    }
    
    var discountedPrice: String? {
        guard product.discountPercentage > 0 else { return nil }
        return product.formattedDiscountedPrice
    }
    
    var hasDiscount: Bool {
        return product.discountPercentage > 0
    }
    
    var discountPercentage: String {
        return String(format: "%.0f%% OFF", product.discountPercentage)
    }
    
    var stockStatus: String {
        switch product.availabilityStatus {
        case "In Stock":
            return "✅ In Stock"
        case "Low Stock":
            return "⚠️ Low Stock"
        default:
            return "❌ Out of Stock"
        }
    }
    
    var rating: String {
        return String(format: "⭐ %.1f", product.rating)
    }
    
    // MARK: - Initialization
    init(product: Product) {
        self.product = product
    }
    
    // MARK: - Methods
    func loadThumbnailImage() {
        guard thumbnailImage == nil else { return }
        
        isImageLoading = true
        
        ImageCache.shared.loadImage(from: product.thumbnail) { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnailImage = image
                self?.isImageLoading = false
            }
        }
    }
    
    func getProduct() -> Product {
        return product
    }
    
    // MARK: - Helper Methods
    func shouldShowDiscountBadge() -> Bool {
        return hasDiscount && product.discountPercentage >= 10
    }
    
    func getPriceAttributedString() -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        if hasDiscount {
            // Original price with strikethrough
            let originalPrice = NSAttributedString(
                string: price,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.secondaryLabel,
                    .font: UIFont.systemFont(ofSize: 14)
                ]
            )
            
            // Discounted price
            let discountPrice = NSAttributedString(
                string: " " + (discountedPrice ?? ""),
                attributes: [
                    .foregroundColor: UIColor.systemGreen,
                    .font: UIFont.boldSystemFont(ofSize: 18)
                ]
            )
            
            attributedString.append(originalPrice)
            attributedString.append(discountPrice)
        } else {
            let regularPrice = NSAttributedString(
                string: price,
                attributes: [
                    .foregroundColor: UIColor.systemGreen,
                    .font: UIFont.boldSystemFont(ofSize: 18)
                ]
            )
            attributedString.append(regularPrice)
        }
        
        return attributedString
    }
}