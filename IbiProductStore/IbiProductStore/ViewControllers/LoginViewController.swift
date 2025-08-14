//
//  LoginViewController.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import UIKit
import Combine
class LoginViewController: UIViewController {
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var biometricButton: UIButton!
    
    private var viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bind text fields to view model using your simple extension
        userTextField.textPublisher
            .compactMap { $0 } // Convert String? to String
            .assign(to: \.username, on: viewModel)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .compactMap { $0 } // Convert String? to String
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        // Set initial values
        viewModel.username = userTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        
        // Bind login button enabled state
        viewModel.isLoginButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)
        
        loginButton.tapPublisher
            .subscribe(viewModel.loginTrigger)
            .store(in: &cancellables)
        
        biometricButton.tapPublisher
            .subscribe(viewModel.loginBioTrigger)
            .store(in: &cancellables)
        
        // Bind loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
    }
    
}
