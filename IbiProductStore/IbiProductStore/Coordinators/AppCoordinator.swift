//
//  AppCoordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import UIKit
import Combine

final class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLogin()
    }
    
    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        childCoordinators.append(loginCoordinator)
        
        // Subscribe to login success
        loginCoordinator.loginSuccessPublisher
            .sink { [weak self] in
                self?.childDidFinish(loginCoordinator)
                self?.showMainApp()
            }
            .store(in: &cancellables)
        
        loginCoordinator.start()
    }
    
    private func showMainApp() {
        let mainCoordinator = MainTabCoordinator(navigationController: navigationController)
        childCoordinators.append(mainCoordinator)
        
        // Subscribe to logout
        mainCoordinator.logoutPublisher
            .sink { [weak self] in
                self?.childDidFinish(mainCoordinator)
                self?.showLogin()
            }
            .store(in: &cancellables)
        
        mainCoordinator.start()
    }
}

class MainTabCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let logoutSubject = PassthroughSubject<Void, Never>()
    var logoutPublisher: AnyPublisher<Void, Never> {
        logoutSubject.eraseToAnyPublisher()
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = UITabBarController()
        
        // Products Tab
        let productsNav = UINavigationController()
        let productsCoordinator = ProductsCoordinator(navigationController: productsNav)
        childCoordinators.append(productsCoordinator)
        productsCoordinator.start()
        productsNav.tabBarItem = UITabBarItem(
            title: "Products",
            image: UIImage(systemName: "list.bullet"),
            tag: 0
        )
//        
//        // Favorites Tab
        let favoritesNav = UINavigationController()
//        let favoritesCoordinator = FavoritesCoordinator(navigationController: favoritesNav)
//        childCoordinators.append(favoritesCoordinator)
//        favoritesCoordinator.start()
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            tag: 1
        )
//        
//        // Settings Tab
        let settingsNav = UINavigationController()
//        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav)
//        childCoordinators.append(settingsCoordinator)
//        
//        // Subscribe to logout from settings
//        settingsCoordinator.logoutPublisher
//            .sink { [weak self] in
//                self?.logoutSubject.send()
//            }
//            .store(in: &settingsCoordinator.cancellables)
//        
//        settingsCoordinator.start()
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            tag: 2
        )
//        
        tabBarController.viewControllers = [productsNav, favoritesNav, settingsNav]
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}

final class LoginCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    private var authService: AuthenticationService!
    
    private let loginSuccessSubject = PassthroughSubject<Void, Never>()
    var loginSuccessPublisher: AnyPublisher<Void, Never> {
        loginSuccessSubject.eraseToAnyPublisher()
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.authService =  AuthenticationService()
    }
    
    func start() {
        let loginViewModel = LoginViewModel(with: authService)
        let loginViewController = LoginViewController(viewModel: loginViewModel)
        
        // Subscribe to login success from ViewModel
        loginViewModel.loginSuccessPublisher
            .sink { [weak self] in
                self?.loginSuccessSubject.send()
            }
            .store(in: &cancellables)
        
        // Subscribe to errors and handle them in coordinator
        loginViewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
        
        navigationController.setViewControllers([loginViewController], animated: false)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
}


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
               // self?.showProductDetail(product: product)
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
    
//    private func showProductDetail(product: Product) {
//        let detailViewController = ProductDetailViewController()
//        let detailViewModel = ProductDetailViewModel(product: product)
//        detailViewController.viewModel = detailViewModel
//        
//        // Subscribe to product updates from detail screen
//        detailViewModel.productUpdatedPublisher
//            .sink { [weak self] updatedProduct in
//                // Update the products list if needed
//                NotificationCenter.default.post(
//                    name: .productUpdated,
//                    object: updatedProduct
//                )
//            }
//            .store(in: &cancellables)
//        
//        navigationController.pushViewController(detailViewController, animated: true)
//    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
}
