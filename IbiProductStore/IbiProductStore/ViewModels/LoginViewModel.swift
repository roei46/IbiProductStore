//
//  LoginViewModel.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import Combine

protocol LoginProtocolType: ObservableObject {
    var username: String { get set }
    var password: String { get set }
    var errorMessage: String? { get set }
    var loginTrigger: PassthroughSubject<Void, Never> { get }
    var loginBioTrigger: PassthroughSubject<Void, Never> { get }
    var loginSuccessPublisher: AnyPublisher<Void, Never> { get }
    var isLoginButtonEnabled: AnyPublisher<Bool, Never> { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
}

class LoginViewModel: LoginProtocolType {
    
    // MARK: - Properties
    private let authService: AuthProtocol
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Input
    @Published var username: String = ""
    @Published var password: String = ""
    
    // MARK: - Output
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    let loginTrigger = PassthroughSubject<Void, Never>()
    let loginBioTrigger = PassthroughSubject<Void, Never>()
    
    
    private let loginSuccessSubject = PassthroughSubject<Void, Never>()
    var loginSuccessPublisher: AnyPublisher<Void, Never> {
        loginSuccessSubject.eraseToAnyPublisher()
    }
    
    var isLoginButtonEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($username, $password)
            .map { username, password in
                !username.isEmpty && !password.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    init(with authService: AuthProtocol) {
        self.authService = authService
        
        loginBioTrigger
            .sink { [weak self] in
                self?.loginWithBiometrics()
            }
            .store(in: &cancellables)
        
        loginTrigger
            .sink { [weak self] in
                self?.login()
            }
            .store(in: &cancellables)
    }
    
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        authService.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] success in
                    if success {
                        self?.authService.setLoggedIn(true)
                        self?.loginSuccessSubject.send()
                    } else {
                        self?.errorMessage = "Invalid username or password"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func loginWithBiometrics() {
        isLoading = true
        errorMessage = nil
        
        authService.authenticateWithBiometrics()
            .sink { [weak self] success in
                self?.isLoading = false
                
                if success {
                    self?.authService.setLoggedIn(true)
                    self?.loginSuccessSubject.send()
                } else {
                    self?.errorMessage = "Biometric authentication failed"
                }
            }
            .store(in: &cancellables)
    }
}
