//
//  LoginViewModelTests.swift
//  IbiProductStoreTests
//
//  Created by Roei Baruch on 16/08/2025.
//

import Testing
import Combine
import XCTest

class MockAuthService: AuthProtocol {
    var shouldSucceed = true

    func login(username: String, password: String) -> AnyPublisher<Bool, Never> {
        return Just(shouldSucceed)
            .delay(for: .seconds(4), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func authenticateWithBiometrics() -> AnyPublisher<Bool, Never> {
        return Just(shouldSucceed).eraseToAnyPublisher()
    }

    func setLoggedIn(_ loggedIn: Bool) {}
    func isLoggedIn() -> Bool { return false }
    func logout() {}
}

@testable import IbiProductStore

class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockAuth: MockAuthService!
    
    
    override func setUp() {
        mockAuth = MockAuthService()
        
        viewModel = LoginViewModel(with: mockAuth)
        cancellables = Set<AnyCancellable>()
    }
    
    func testLoginButtonEnabled() {
        viewModel.username = "admin"
        viewModel.password = "password"
        
        viewModel.isLoginButtonEnabled
            .sink { isEnabled in
                XCTAssertTrue(isEnabled)
            }
            .store(in: &cancellables)
    }

    func testLoginSuccess() {
         let expectation = XCTestExpectation(description: "Login succeeds")
         mockAuth.shouldSucceed = true
         viewModel.username = "admin"
         viewModel.password = "password"

         viewModel.loginSuccessPublisher
             .sink { _ in
                 expectation.fulfill()
             }
             .store(in: &cancellables)

         viewModel.loginTrigger.send()

         wait(for: [expectation], timeout: 5.0)
         XCTAssertNil(viewModel.errorMessage)
         XCTAssertFalse(viewModel.isLoading)
     }
}


