//
//  ProductViewModel.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import Combine

class ProductsViewModel {
    
    // MARK: - Properties
    private let networkService: ProductService
//    private let storageService = ProductsStorageService.shared
    private var cancellables = Set<AnyCancellable>()
    
//    private var currentPage = 0
//    private let itemsPerPage = 20
    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var hasMorePages = true
    @Published var errorMessage: String?
    
    // MARK: - Output Publishers
    private let productSelectedSubject = PassthroughSubject<Product, Never>()
    var productSelectedPublisher: AnyPublisher<Product, Never> {
        productSelectedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Computed Properties
    var numberOfProducts: Int {
        return products.count
    }
    
    // MARK: - Initialization
    init(productService: ProductService = .init()) {
        self.networkService = productService
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for product updates
//        NotificationCenter.default.publisher(for: .productUpdated)
//            .compactMap { $0.object as? Product }
//            .sink { [weak self] updatedProduct in
//                self?.updateProduct(updatedProduct)
//            }
//            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func loadProducts() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response: ProductResponse = try await networkService.getProduct()
                
                await MainActor.run {
                    self.products = response.products
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
    

    func product(at index: Int) -> Product {
        return products[index]
    }
    
//    func selectProduct(at index: Int) {
//        let product = products[index]
//        productSelectedSubject.send(product)
//    }
//    
//    func addNewProduct(_ product: Product) {
//        storageService.addProduct(product)
//        products.insert(product, at: 0)
//    }
//    
//    func updateProduct(_ product: Product) {
//        storageService.saveModifiedProduct(product)
//        
//        if let index = products.firstIndex(where: { $0.id == product.id }) {
//            products[index] = product
//        }
//    }
//    
//    func deleteProduct(at index: Int) {
//        let product = products[index]
//        storageService.deleteProduct(product.id)
//        products.remove(at: index)
//    }
//    
//    func resetLocalChanges() {
//        storageService.resetLocalChanges()
//        loadProducts(reset: true)
//    }
//    
//    private func handleProductsResponse(_ response: ProductResponse, reset: Bool) {
//        let modifiedProducts = storageService.getModifiedProducts()
//        let deletedIds = storageService.getDeletedProductIds()
//        let addedProducts = storageService.getAddedProducts()
//        
//        // Filter out deleted products and apply modifications
//        var processedProducts = response.products
//            .filter { !deletedIds.contains($0.id) }
//            .map { modifiedProducts[$0.id] ?? $0 }
//        
//        if reset {
//            // Add custom products at the beginning
//            processedProducts = addedProducts + processedProducts
//            products = processedProducts
//        } else {
//            products.append(contentsOf: processedProducts)
//        }
//        
//        hasMorePages = response.products.count == itemsPerPage
//        isLoading = false
//    }
}
