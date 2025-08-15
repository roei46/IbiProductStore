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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let favoritesViewModel = FavoritesViewModel()
        let favoritesViewController = TableViewWithTitleViewController(viewModel: favoritesViewModel)

        // Subscribe to product selection
        favoritesViewModel.productSelectedPublisher
            .sink { [weak self] product in
                guard let self = self else { return }
                self.showProductDetail(product: product, cancellables: &self.cancellables)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(favoritesViewController, animated: false)
    }
}