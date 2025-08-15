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

enum AppLanguage: String {
    case english = "en"
    case hebrew = "he"
}

private var bundleKey: UInt8 = 0

extension Bundle {
    static let once: Void = {
        object_setClass(Bundle.main, PrivateBundle.self)
    }()

    class func setLanguage(_ language: String) {
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")!), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private class PrivateBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}
