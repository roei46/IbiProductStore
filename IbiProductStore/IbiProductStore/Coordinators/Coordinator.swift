//
//  Coordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import UIKit
import Combine

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func childDidFinish(_ child: Coordinator?)
}

extension Coordinator {
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    func showProductDetail(product: Product, cancellables: inout Set<AnyCancellable>) {
        let detailViewModel = ProductDetailViewModel(product: product)
        let detailViewController = DetailsViewController(viewModel: detailViewModel)

        detailViewModel.closeTrigger
            .sink { [weak self] _ in
                self?.navigationController.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
