//
//  FavoritesCoordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import UIKit
import Combine

class FavoritesCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    private let storageService: LocalStorageServiceProtocol
    
    init(navigationController: UINavigationController, storageService: LocalStorageServiceProtocol) {
        self.navigationController = navigationController
        self.storageService = storageService
    }
    
    func start() {
        let favoritesViewModel = FavoritesViewModel(localStorageService: storageService)
        let favoritesViewController = TableViewWithTitleViewController(viewModel: favoritesViewModel)

        // Subscribe to product selection
        favoritesViewModel.productSelectedPublisher
            .sink { [weak self] product in
                guard let self = self else { return }
                self.showProductDetail(mode: .edit(product), cancellables: &self.cancellables)
            }
            .store(in: &cancellables)
        
        // Subscribe to errors and handle them in coordinator
        favoritesViewModel.errorMessagePublisher
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(favoritesViewController, animated: false)
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
