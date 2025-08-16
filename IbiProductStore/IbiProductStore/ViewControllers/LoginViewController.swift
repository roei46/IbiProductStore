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
    
    private var viewModel: any LoginProtocolType
    private var cancellables = Set<AnyCancellable>()
    
    
    init(viewModel: any LoginProtocolType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTextField.textPublisher
            .compactMap { $0 }
            .assign(to: \.username, on: viewModel)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .compactMap { $0 }
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.username = userTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        
        viewModel.isLoginButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)
        
        loginButton.tapPublisher
            .subscribe(viewModel.loginTrigger)
            .store(in: &cancellables)
        loginButton
            .bindLoading(to: viewModel.isLoadingPublisher, animationName: "loader", cancellables: &cancellables)
        
        biometricButton.tapPublisher
            .subscribe(viewModel.loginBioTrigger)
            .store(in: &cancellables)
        
    }
    
}
