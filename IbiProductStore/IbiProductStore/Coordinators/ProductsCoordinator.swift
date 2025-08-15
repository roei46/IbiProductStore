//
//  ProductsCoordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import UIKit
import Combine

class ProductsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let productsViewModel = ProductsViewModel()
        let productsViewController = TableViewWithTitleViewController(viewModel: productsViewModel)
                
        // Subscribe to product selection
        productsViewModel.productSelectedPublisher
            .sink { [weak self] product in
                guard let self = self else { return }
                self.showProductDetail(product: product, cancellables: &self.cancellables)
            }
            .store(in: &cancellables)
        
        // Subscribe to errors and handle them in coordinator
        productsViewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(productsViewController, animated: false)
    }
}