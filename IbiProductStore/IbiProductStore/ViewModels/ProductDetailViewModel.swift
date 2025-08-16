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
    private let mode: DetailMode
    
    // MARK: - Published Properties
    @Published private(set) var isFavorite: Bool = false
    @Published var isEditing: Bool = false
    @Published var errorMessage: String?
    
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
    var errorMessagePublisher: AnyPublisher<String, Never> { $errorMessage.compactMap { $0 }.eraseToAnyPublisher() }
    
    // MARK: - Triggers (like LoginViewModel pattern)
    let closeTrigger = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization
    init(mode: DetailMode, localStorageService: LocalStorageServiceProtocol) {
        self.mode = mode
        self.localStorageService = localStorageService
        
        switch mode {
        case .edit(let product):
            self.product = product
            self.isFavorite = product.isFavorite
            self.editableTitle = product.title
            self.editableDescription = product.description
            self.editablePrice = product.formattedPrice
        case .add:
            // Placeholder product - real product created in saveChanges
            self.product = Product(
                id: 0, title: "", description: "", category: "", price: 0,
                discountPercentage: 0, rating: 0, stock: 0, tags: [], brand: "",
                sku: "", weight: 0, dimensions: Dimensions(width: 0, height: 0, depth: 0),
                warrantyInformation: "", shippingInformation: "", availabilityStatus: "",
                reviews: [], returnPolicy: "", minimumOrderQuantity: 0,
                meta: Meta(createdAt: "", updatedAt: "", barcode: "", qrCode: ""),
                images: [], thumbnail: ""
            )
            self.isFavorite = false
            self.editableTitle = ""
            self.editableDescription = ""
            self.editablePrice = "0.00"
            self.isEditing = true
        }
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
        editablePrice = product.price.isFinite ? String(format: "%.2f", product.price) : "0.00"
    }
    
    func saveChanges() {
        // Validate and convert price
        guard let priceValue = Double(editablePrice) else {
            print("Invalid price format")
            return
        }
        
        switch mode {
        case .edit(let originalProduct):
            // Edit mode - update existing product
            let updatedProduct = Product(
                id: originalProduct.id,
                title: editableTitle,
                description: editableDescription,
                category: originalProduct.category,
                price: priceValue,
                discountPercentage: originalProduct.discountPercentage,
                rating: originalProduct.rating,
                stock: originalProduct.stock,
                tags: originalProduct.tags,
                brand: originalProduct.brand,
                sku: originalProduct.sku,
                weight: originalProduct.weight,
                dimensions: originalProduct.dimensions,
                warrantyInformation: originalProduct.warrantyInformation,
                shippingInformation: originalProduct.shippingInformation,
                availabilityStatus: originalProduct.availabilityStatus,
                reviews: originalProduct.reviews,
                returnPolicy: originalProduct.returnPolicy,
                minimumOrderQuantity: originalProduct.minimumOrderQuantity,
                meta: originalProduct.meta,
                images: originalProduct.images,
                thumbnail: originalProduct.thumbnail
            )
            
            // Update local product
            self.product = updatedProduct
            
            // Save to local storage as modified
            do {
                try localStorageService.saveModifiedProducts([updatedProduct])
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            // Exit edit mode
            isEditing = false
            
        case .add:
            // Add mode - create new product from user input
            let newProduct = Product(
                id: Int.random(in: 10000...99999),
                title: editableTitle.isEmpty ? "New Product" : editableTitle,
                description: editableDescription.isEmpty ? "No description" : editableDescription,
                category: "General",
                price: priceValue,
                discountPercentage: 0,
                rating: 4.5,
                stock: 1,
                tags: [],
                brand: "",
                sku: "SKU-\(Int.random(in: 10000...99999))",
                weight: 0,
                dimensions: Dimensions(width: 0, height: 0, depth: 0),
                warrantyInformation: "",
                shippingInformation: "",
                availabilityStatus: "In Stock",
                reviews: [],
                returnPolicy: "",
                minimumOrderQuantity: 1,
                meta: Meta(createdAt: "", updatedAt: "", barcode: "", qrCode: ""),
                images: [],
                thumbnail: ""
            )
            
            // Update local product
            self.product = newProduct
            
            // Save new product to local storage
            do {
                var addedProducts = try localStorageService.loadAddedProducts()
                addedProducts.append(newProduct)
                try localStorageService.saveAddedProducts(addedProducts)
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            // Close the detail view after adding
            closeTrigger.send()
        }
    }
    
    func cancelEditing() {
        // Reset editable fields to original values
        editableTitle = product.title
        editableDescription = product.description
        editablePrice = product.price.isFinite ? String(format: "%.2f", product.price) : "0.00"
        
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
