//
//  ProductDetailViewModel.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import Combine

class ProductDetailViewModel: DetailsProtocol, ObservableObject {
    
    // MARK: - Properties
    private var product: Product
    private let localStorageService: LocalStorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    @Published private(set) var isFavorite: Bool = false
    @Published var isEditing: Bool = false
    
    // MARK: - Editable Properties
    @Published var editableTitle: String = ""
    @Published var editableDescription: String = ""
    @Published var editablePrice: String = ""
    
    // MARK: - DetailsProtocol Properties
    var title: String {
        return product.title
    }
    
    var subtitle: String? {
        return product.brand
    }
    
    var price: String? {
        return product.formattedPrice
    }
    
    var description: String {
        return product.description
    }
    
    var imageUrls: [String] {
        return product.images
    }
    
    // MARK: - Publisher Properties
    var isFavoritePublisher: AnyPublisher<Bool, Never> { $isFavorite.eraseToAnyPublisher() }
    var isEditingPublisher: AnyPublisher<Bool, Never> { $isEditing.eraseToAnyPublisher() }
    var editableTitlePublisher: AnyPublisher<String, Never> { $editableTitle.eraseToAnyPublisher() }
    var editablePricePublisher: AnyPublisher<String, Never> { $editablePrice.eraseToAnyPublisher() }
    var editableDescriptionPublisher: AnyPublisher<String, Never> { $editableDescription.eraseToAnyPublisher() }
    
    // MARK: - Triggers (like LoginViewModel pattern)
    let closeTrigger = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization
    init(product: Product, localStorageService: LocalStorageServiceProtocol = CoreDataStorageService.shared) {
        self.product = product
        self.localStorageService = localStorageService
        self.isFavorite = product.isFavorite
        
        // Initialize editable fields
        self.editableTitle = product.title
        self.editableDescription = product.description
        self.editablePrice = product.formattedPrice
    }
    
    // MARK: - DetailsProtocol Methods
    
    func edit() {
        startEditing()
    }
    
    // MARK: - Edit Methods
    func startEditing() {
        isEditing = true
        // Reset editable fields to current values
        editableTitle = product.title
        editableDescription = product.description
        editablePrice = String(format: "%.2f", product.price)
    }
    
    func saveChanges() {
        // Validate and convert price
        guard let priceValue = Double(editablePrice) else {
            print("Invalid price format")
            return
        }
        
        // Create new product with updated values
        let updatedProduct = Product(
            id: product.id,
            title: editableTitle,
            description: editableDescription,
            category: product.category,
            price: priceValue,
            discountPercentage: product.discountPercentage,
            rating: product.rating,
            stock: product.stock,
            tags: product.tags,
            brand: product.brand,
            sku: product.sku,
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
        
        // Update local product
        self.product = updatedProduct
        
        // Save to local storage as modified
        localStorageService.saveModifiedProducts([updatedProduct])
        
        // Exit edit mode
        isEditing = false
    }
    
    func cancelEditing() {
        // Reset editable fields to original values
        editableTitle = product.title
        editableDescription = product.description
        editablePrice = String(format: "%.2f", product.price)
        
        isEditing = false
    }
    
    func toggleFavorite() {
        var updatedProduct = product
        updatedProduct.isFavorite.toggle()
        
        localStorageService.toggleFavorite(updatedProduct)
        isFavorite = updatedProduct.isFavorite
    }
    
    func shareContent() -> String {
        return """
        Check out this product!
        
        \(product.title)
        \(product.brand ?? "")
        \(product.formattedPrice)
        
        \(product.description)
        """
    }
}
