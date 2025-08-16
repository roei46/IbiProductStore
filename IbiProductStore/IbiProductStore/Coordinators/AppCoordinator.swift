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
        
        mainCoordinator.logoutPublisher
            .sink { [weak self] in
                self?.childDidFinish(mainCoordinator)
                self?.showLogin()
            }
            .store(in: &cancellables)
        
        mainCoordinator.start()
    }
}
