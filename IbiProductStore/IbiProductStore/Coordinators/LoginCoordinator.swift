//
//  LoginCoordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import UIKit
import Combine

final class LoginCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    private var authService: AuthProtocol
    
    private let loginSuccessSubject = PassthroughSubject<Void, Never>()
    var loginSuccessPublisher: AnyPublisher<Void, Never> {
        loginSuccessSubject.eraseToAnyPublisher()
    }
    
    init(navigationController: UINavigationController, authService: AuthProtocol = AuthenticationService()) {
        self.navigationController = navigationController
        self.authService = authService
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
}
