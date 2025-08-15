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
    
    // MARK: - Computed Properties
    var numberOfProducts: Int { get }
    var screenTitle: String { get }
    
    // MARK: - Methods
    func cellViewModel(at index: Int) -> ProductCellViewModel
    func product(at index: Int) -> Product
    func loadProducts()
    func refreshData()
    func refreshOnAppear()
    
    // MARK: - Favorites Management
    func toggleFavorite(at index: Int)
    func isFavorite(_ product: Product) -> Bool
    
    // MARK: - CRUD Operations
    func canEdit() -> Bool
//    func canAdd() -> Bool
    func editProduct(at index: Int, with product: Product)
    func addProduct(_ product: Product)
    func deleteProduct(at index: Int)
    func resetToServer()
}

// MARK: - Default Implementations
extension ProductListProtocol {
    // TODO: - SHOWERROR FOR ALL COORDINATORS?
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
        loadProducts()  // Default: just reload data
    }
    
    // Default CRUD implementations (can be overridden)
    func canEdit() -> Bool { return false }
//    func canAdd() -> Bool { return false }
    func editProduct(at index: Int, with product: Product) { }
    func addProduct(_ product: Product) { }
    func deleteProduct(at index: Int) { }
    func resetToServer() { }
}
// TODO: - DO FROM SCRATCH IN SWIFTUI 
