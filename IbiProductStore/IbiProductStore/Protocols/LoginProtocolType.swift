//
//  LoginProtocolType.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 16/08/2025.
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
