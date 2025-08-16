//
//  SettingsCoordinator.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import Combine
import UIKit

final class SettingsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var cancellables = Set<AnyCancellable>()
    
    private let logoutSubject = PassthroughSubject<Void, Never>()
    var logoutPublisher: AnyPublisher<Void, Never> {
        logoutSubject.eraseToAnyPublisher()
    }

    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let settingsViewModel = SettingsViewModel()
        let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
        
        settingsViewModel.logOutTrigger
            .sink { [weak self] in
                self?.logoutSubject.send(())
        }.store(in: &cancellables)
        
        
        navigationController.pushViewController(settingsViewController, animated: false)
    }
}

