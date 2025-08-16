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
    private let userDefaults = UserDefaultsService.shared

    // MARK: - Published Properties
    @Published var cellViewModels: [ProductCellViewModel] = []
    @Published var isLoading = false
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
    
    // MARK: - Triggers (Not used in favorites)
    let resetTrigger = PassthroughSubject<Void, Never>()
    var resetTriggerPublisher: AnyPublisher<Void, Never> {
        resetTrigger.eraseToAnyPublisher()
    }
    
    // MARK: - Publishers (Protocol Requirement)
    var cellViewModelsPublisher: Published<[ProductCellViewModel]>.Publisher { $cellViewModels }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    
    // MARK: - Computed Properties
    @Published var screenTitle: String = "fav".localized
    @Published var subTitle: String = "all_products".localized

    var screenTitlePublisher: Published<String>.Publisher { $screenTitle }
    var screenSubTitlePublisher: Published<String>.Publisher { $subTitle }

    // MARK: - Initialization
    init(localStorageService: LocalStorageServiceProtocol) {
        self.localStorageService = localStorageService
        setupBindings()
        loadProducts()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        userDefaults.$currentLanguage
            .sink { [weak self] _ in
                self?.updateLabels()
            }
            .store(in: &cancellables)
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
    
    private func updateLabels() {
        screenTitle = "all_fav".localized
        subTitle = "fav".localized
    }
    
    func navigateToDetail(at index: Int) {
        let product = self.product(at: index)
        productSelectedSubject.send(product)
    }
    
    func cellViewModel(at index: Int) -> ProductCellViewModel {
        return cellViewModels[index]
    }
    
    func product(at index: Int) -> Product {
        return cellViewModels[index].getProduct()
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
    
    func addProduct() {}
    
    // MARK: - Private Methods
    private func createCellViewModels(from products: [Product]) {
        cellViewModels = products.map { product in
            let cellViewModel = ProductCellViewModel(product: product)
            // Mark as favorite since this is favorites screen
            return cellViewModel
        }
    }
}
