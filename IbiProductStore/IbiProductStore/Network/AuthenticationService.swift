//
//  AuthenticationService.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import Combine
import LocalAuthentication

final class AuthenticationService {
    
    private let testUser = User(username: "testuser", password: "password123")
    
    
    
    init() {}
    
    
    func login(username: String, password: String) -> AnyPublisher<Bool, Never> {
        let isValid = username == testUser.username && password == testUser.password
        let subject = PassthroughSubject<Bool, Never>()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            subject.send(isValid)
            subject.send(completion: .finished)
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func authenticateWithBiometrics() -> AnyPublisher<Bool, Never> {
        let subject = PassthroughSubject<Bool, Never>()
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return Just(false).eraseToAnyPublisher()
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access your account"
        ) { success, _ in
            DispatchQueue.main.async {
                subject.send(success)
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
    }
    
    func setLoggedIn(_ isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
}

