//
//  MainTabCoordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import UIKit
import Combine

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
        let favoritesCoordinator = FavoritesCoordinator(navigationController: favoritesNav)
        childCoordinators.append(favoritesCoordinator)
        favoritesCoordinator.start()
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            tag: 1
        )

        // Settings Tab
        let settingsNav = UINavigationController()
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav)
        childCoordinators.append(settingsCoordinator)
  
        // Subscribe to logout from settings
        settingsCoordinator.logoutPublisher
            .sink { [weak self] in
                self?.logoutSubject.send()
            }
            .store(in: &settingsCoordinator.cancellables)

        settingsCoordinator.start()
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            tag: 2
        )
        
        tabBarController.viewControllers = [productsNav, favoritesNav, settingsNav]
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}
