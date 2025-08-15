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
    
    private let addProductSubject = PassthroughSubject<Void, Never>()
    var addProductPublisher: AnyPublisher<Void, Never> {
        addProductSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Triggers
    let resetTrigger = PassthroughSubject<Void, Never>()
    var resetTriggerPublisher: AnyPublisher<Void, Never> {
        resetTrigger.eraseToAnyPublisher()
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
    
    func addProduct() {
        addProductSubject.send()
    }

    func cellViewModel(at index: Int) -> ProductCellViewModel {
        return cellViewModels[index]
    }
    
    func navigateToDetail(at index: Int) {
        let product = self.product(at: index)
        productSelectedSubject.send(product)
    }
    
    func product(at index: Int) -> Product {
        return cellViewModels[index].getProduct()
    }
    
    // MARK: - ProductListProtocol Implementation
    func toggleFavorite(at index: Int) {
        var product = product(at: index)
        print("🔄 Before toggle: \(product.title) - isFavorite: \(product.isFavorite)")
        product.isFavorite.toggle()
        print("🔄 After toggle: \(product.title) - isFavorite: \(product.isFavorite)")
        
        // Update the product in the array by ID
        if let productIndex = products.firstIndex(where: { $0.id == product.id }) {
            products[productIndex] = product
            print("✅ Updated product in array at index: \(productIndex)")
        }
        
        // Save to Core Data
        localStorageService.toggleFavorite(product)
    }
    
    func isFavorite(_ product: Product) -> Bool {
        return localStorageService.isFavorite(product)
    }
    
    // MARK: - CRUD Operations
    func canEdit() -> Bool { return true }
    
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
        
        // Reset to original products and reload
        products = originalProducts
        loadProducts()
    }
    
    // Override to prevent unnecessary reloads on products screen
    func refreshOnAppear() {
        if products.isEmpty {
            // Load from server if no products
            loadProducts()
        } else {
            // Refresh local changes (favorites, modifications) when returning to screen
            applyLocalChanges(to: originalProducts)
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
        let favoriteProducts = localStorageService.loadFavorites()
        
        // Create dictionaries for quick lookup
        let modifiedDict = Dictionary(uniqueKeysWithValues: modifiedProducts.map { ($0.id, $0) })
        let favoriteIds = Set(favoriteProducts.map { $0.id })
        
        // Filter out deleted products, apply modifications, and set favorite status
        var processedProducts = serverProducts
            .filter { !deletedIds.contains($0.id) }
            .map { product in
                var finalProduct = modifiedDict[product.id] ?? product
                finalProduct.isFavorite = favoriteIds.contains(product.id)
                return finalProduct
            }
        
        // Add custom products at the beginning
        processedProducts = addedProducts + processedProducts
        
        self.products = processedProducts
    }
}
