//
//  ProductsCoordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import UIKit
import Combine

final class ProductsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    private var storageService: LocalStorageServiceProtocol
    
    init(navigationController: UINavigationController, storageService: LocalStorageServiceProtocol) {
        self.navigationController = navigationController
        self.storageService = storageService
    }
    
    func start() {
        let productsViewModel = ProductsViewModel(localStorageService: storageService)
        let productsViewController = TableViewWithTitleViewController(viewModel: productsViewModel)
                
        // Subscribe to product selection (edit mode)
        productsViewModel.productSelectedPublisher
            .sink { [weak self] product in
                guard let self = self else { return }
                self.showProductDetail(mode: .edit(product), cancellables: &self.cancellables)
            }
            .store(in: &cancellables)
        
        // Subscribe to add product (add mode)
        productsViewModel.addProductPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.showProductDetail(mode: .add, cancellables: &self.cancellables)
            }
            .store(in: &cancellables)
        
        // Subscribe to reset trigger
        productsViewModel.resetTriggerPublisher
            .sink { [weak self] in
                self?.handleResetTrigger(viewModel: productsViewModel)
            }
            .store(in: &cancellables)
        
        // Subscribe to errors and handle them in coordinator
        productsViewModel.errorMessagePublisher
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(productsViewController, animated: false)
    }
    
    private func handleResetTrigger(viewModel: ProductsViewModel) {
        let alert = UIAlertController(
            title: "Reset Products",
            message: "This will reset all changes and reload from server. Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) {  _ in
            viewModel.resetToServer()
        })
        
        navigationController.present(alert, animated: true)
    }
    
    private func showProductDetail(mode: DetailMode, cancellables: inout Set<AnyCancellable>) {
        let detailViewModel = ProductDetailViewModel(mode: mode, localStorageService: storageService)
        let detailViewController = DetailsViewController(viewModel: detailViewModel)
        
        detailViewModel.errorMessagePublisher
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)

        detailViewModel.closeTrigger
            .sink { [weak self] _ in
                self?.navigationController.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
