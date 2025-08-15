//
//  FavoritesViewModel.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import Combine

class FavoritesViewModel: ProductListProtocol {
    
    // MARK: - Properties
    private let localStorageService: LocalStorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    @Published var cellViewModels: [ProductCellViewModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Publishers
    var cellViewModelsPublisher: Published<[ProductCellViewModel]>.Publisher { $cellViewModels }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    
    // MARK: - Computed Properties
    var screenTitle: String {
        return "Favorites"
    }
    
    // MARK: - Initialization
    init(localStorageService: LocalStorageServiceProtocol = CoreDataStorageService.shared) {
        self.localStorageService = localStorageService
        setupBindings()
        loadProducts()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // No need for NotificationCenter - will reload in viewWillAppear
    }
    
    // MARK: - ProductListProtocol Implementation
    func loadProducts() {
        isLoading = true
        errorMessage = nil
        
        // Load favorites from local storage
        let favorites = localStorageService.loadFavorites()
        createCellViewModels(from: favorites)
        
        isLoading = false
    }
    
    func toggleFavorite(at index: Int) {
        let product = product(at: index)
        localStorageService.removeFromFavorites(product)
        
        // Remove from current list
        cellViewModels.remove(at: index)
    }
    
    func isFavorite(_ product: Product) -> Bool {
        return localStorageService.isFavorite(product)
    }
    
    // MARK: - CRUD Operations (Not supported for favorites)
    func canEdit() -> Bool { return false }
    func canAdd() -> Bool { return false }
    
    // MARK: - Private Methods
    private func createCellViewModels(from products: [Product]) {
        cellViewModels = products.map { product in
            let cellViewModel = ProductCellViewModel(product: product)
            // Mark as favorite since this is favorites screen
            return cellViewModel
        }
    }
}
