//
//  ProductViewModel.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import Combine

class ProductsViewModel: ProductListProtocol {
    
    // MARK: - Properties
    private let networkService: ProductService
    private let localStorageService: LocalStorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var originalProducts: [Product] = [] 
    

    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var cellViewModels: [ProductCellViewModel] = []
    @Published var isLoading = false
    @Published var hasMorePages = true
    @Published var errorMessage: String?
    
    // MARK: - Output Publishers
    private let productSelectedSubject = PassthroughSubject<Product, Never>()
    var productSelectedPublisher: AnyPublisher<Product, Never> {
        productSelectedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Publishers (Protocol Requirement)
    var cellViewModelsPublisher: Published<[ProductCellViewModel]>.Publisher { $cellViewModels }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    
    // MARK: - Computed Properties
    var screenTitle: String {
        return "Products"
    }
    
    // MARK: - Initialization
    init(productService: ProductService = .init(), localStorageService: LocalStorageServiceProtocol = CoreDataStorageService.shared) {
        self.networkService = productService
        self.localStorageService = localStorageService
        setupBindings()
    }
    
    private func setupBindings() {
        // Create cell ViewModels when products change
        $products
            .sink { [weak self] products in
                self?.createCellViewModels(from: products)
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Methods
    func loadProducts() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // TODO: - CHECK ASYNC LET??
                let response: ProductResponse = try await networkService.getProduct()
                
                await MainActor.run {
                    self.originalProducts = response.products
                    self.applyLocalChanges(to: response.products)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    

    func cellViewModel(at index: Int) -> ProductCellViewModel {
        return cellViewModels[index]
    }
    
    func product(at index: Int) -> Product {
        return cellViewModels[index].getProduct()
    }
    
    // MARK: - ProductListProtocol Implementation
    func toggleFavorite(at index: Int) {
        // TODO: - Maybe add so Product is favorite?
        let product = product(at: index)
        localStorageService.toggleFavorite(product)
    }
    
    func isFavorite(_ product: Product) -> Bool {
        return localStorageService.isFavorite(product)
    }
    
    // MARK: - CRUD Operations
    func canEdit() -> Bool { return true }
    func canAdd() -> Bool { return true }
    
    func editProduct(at index: Int, with updatedProduct: Product) {
        // Update in current list
        products[index] = updatedProduct
        
        // Save to local storage
        var modifiedProducts = localStorageService.loadModifiedProducts()
        if let existingIndex = modifiedProducts.firstIndex(where: { $0.id == updatedProduct.id }) {
            modifiedProducts[existingIndex] = updatedProduct
        } else {
            modifiedProducts.append(updatedProduct)
        }
        localStorageService.saveModifiedProducts(modifiedProducts)
    }
    
    func addProduct(_ product: Product) {
        // Add to current list
        products.insert(product, at: 0)
        
        // Save to local storage
        var addedProducts = localStorageService.loadAddedProducts()
        addedProducts.append(product)
        localStorageService.saveAddedProducts(addedProducts)
    }
    
    func deleteProduct(at index: Int) {
        let product = products[index]
        
        // Remove from current list
        products.remove(at: index)
        
        // Add to deleted IDs
        var deletedIds = localStorageService.loadDeletedProductIds()
        deletedIds.append(product.id)
        localStorageService.saveDeletedProductIds(deletedIds)
        
        // Remove from favorites if it was favorited
        if localStorageService.isFavorite(product) {
            localStorageService.removeFromFavorites(product)
        }
    }
    
    func resetToServer() {
        // Clear all local changes
        localStorageService.clearAllLocalData()
        
        // Reset to original products
        products = originalProducts
    }
    
    // Override to prevent unnecessary reloads on products screen
    func refreshOnAppear() {
        // Products screen doesn't need to reload on appear since it loads from server once
        // Only reload if there are no products
        if products.isEmpty {
            loadProducts()
        }
    }
    
    // MARK: - Private Methods
    private func createCellViewModels(from products: [Product]) {
        cellViewModels = products.map { ProductCellViewModel(product: $0) }
    }
    
    private func applyLocalChanges(to serverProducts: [Product]) {
        let modifiedProducts = localStorageService.loadModifiedProducts()
        let addedProducts = localStorageService.loadAddedProducts()
        let deletedIds = localStorageService.loadDeletedProductIds()
        
        // Create dictionary for quick lookup of modified products
        let modifiedDict = Dictionary(uniqueKeysWithValues: modifiedProducts.map { ($0.id, $0) })
        
        // Filter out deleted products and apply modifications
        var processedProducts = serverProducts
            .filter { !deletedIds.contains($0.id) }
            .map { modifiedDict[$0.id] ?? $0 }
        
        // Add custom products at the beginning
        processedProducts = addedProducts + processedProducts
        
        self.products = processedProducts
    }
}
