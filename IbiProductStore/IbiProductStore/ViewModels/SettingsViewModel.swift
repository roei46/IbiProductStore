//
//  SettingsViewModel.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import Combine
import UIKit

protocol SettingsType:  ObservableObject {
    var label: String { get }
    var secondaryLabel: String { get }
    var buttonLabel: String { get }

    var isFirstSwitchOn: Bool { get set }
    var isSecondSwitchOn: Bool { get set }
    
    var logOutTrigger: PassthroughSubject<Void, Never> { get set }
}

final class SettingsViewModel: SettingsType{
    var label = NSLocalizedString("dark_mode", comment: "")
    var secondaryLabel = NSLocalizedString("language", comment: "")
    var buttonLabel = NSLocalizedString("log_out", comment: "")
  
    
    private var cancellables = Set<AnyCancellable>()

    @Published var isFirstSwitchOn: Bool = false
    @Published var isSecondSwitchOn: Bool = false
    var logOutTrigger = PassthroughSubject<Void, Never>()

    init () {
        
        $isFirstSwitchOn
            .sink { [weak self] on in
                self?.toggleDarkMode(isOn: on)
        }
        .store(in: &cancellables)
        
        $isSecondSwitchOn
            .sink { [weak self] on in
                self?.toggleLanguage(isOn: on)
        }
        .store(in: &cancellables)
    }
    
    private func toggleDarkMode(isOn: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let window = windowScene.windows.first {
              window.overrideUserInterfaceStyle = isOn ? .dark : .light
          }
    }
    
    private func toggleLanguage(isOn: Bool) {
        Bundle.setLanguage(isOn ? AppLanguage.english.rawValue : AppLanguage.hebrew.rawValue)

    }
}
