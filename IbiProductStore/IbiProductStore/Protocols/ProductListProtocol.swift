//
//  ProductListProtocol.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import Combine

protocol ProductListProtocol: ObservableObject {
    // MARK: - Published Properties
    var cellViewModels: [ProductCellViewModel] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    // MARK: - Publishers
    var cellViewModelsPublisher: Published<[ProductCellViewModel]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    
    // MARK: - Triggers
    var resetTrigger: PassthroughSubject<Void, Never> { get }
    var resetTriggerPublisher: AnyPublisher<Void, Never> { get }
    
    // MARK: - Computed Properties
    var numberOfProducts: Int { get }
    var screenTitlePublisher: Published<String>.Publisher { get }
    var screenSubTitlePublisher: Published<String>.Publisher { get }

    
    // MARK: - Methods
    func cellViewModel(at index: Int) -> ProductCellViewModel
    func product(at index: Int) -> Product
    func loadProducts()
    func loadMoreProducts()
    func refreshData()
    func refreshOnAppear()
    func navigateToDetail(at index: Int)
    func addProduct() 
    
    // MARK: - Favorites Management
    func toggleFavorite(at index: Int)
    func isFavorite(_ product: Product) -> Bool
    
    // MARK: - CRUD Operations
    func canEdit() -> Bool
}

// MARK: - Default Implementations
extension ProductListProtocol {
    var numberOfProducts: Int {
        return cellViewModels.count
    }
    
    func cellViewModel(at index: Int) -> ProductCellViewModel {
        return cellViewModels[index]
    }
    
    func product(at index: Int) -> Product {
        return cellViewModels[index].getProduct()
    }
    
    func refreshData() {
        loadProducts()
    }
    
    func refreshOnAppear() {
        loadProducts()
    }
    
    // Default CRUD implementations (can be overridden)
    func canEdit() -> Bool { return false }
    func deleteProduct(at index: Int) { }
    func loadMoreProducts() { }
}
// TODO: - DO FROM SCRATCH IN SWIFTUI
