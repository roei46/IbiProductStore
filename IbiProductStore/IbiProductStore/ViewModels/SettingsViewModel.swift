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
    var label: String { get set }
    var secondaryLabel: String { get set }
    var buttonLabel: String { get set }
    var isFirstSwitchOn: Bool { get set }
    var isSecondSwitchOn: Bool { get set }
    var logOutTrigger: PassthroughSubject<Void, Never> { get set }
}

final class SettingsViewModel: SettingsType{
    @Published var label: String = "dark_mode".localized
    @Published var secondaryLabel: String = "language".localized  
    @Published var buttonLabel: String = "log_out".localized
  
    private let userDefaults = UserDefaultsService.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var isFirstSwitchOn: Bool = false
    @Published var isSecondSwitchOn: Bool = false
    var logOutTrigger = PassthroughSubject<Void, Never>()

    init () {
        // Load saved preferences
        isFirstSwitchOn = userDefaults.isDarkMode
        isSecondSwitchOn = userDefaults.selectedLanguage == "he"
        
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
        
        // Observe language changes and update labels
        userDefaults.$currentLanguage
            .sink { [weak self] _ in
                self?.updateLabels()
            }
            .store(in: &cancellables)
    }
    
    private func updateLabels() {
        label = "dark_mode".localized
        secondaryLabel = "language".localized
        buttonLabel = "log_out".localized
    }
    
    private func toggleDarkMode(isOn: Bool) {
        userDefaults.isDarkMode = isOn
    }
    
    private func toggleLanguage(isOn: Bool) {
        userDefaults.selectedLanguage = isOn ? "he" : "en"
    }
}
