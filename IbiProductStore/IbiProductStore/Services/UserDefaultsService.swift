//
//  UserDefaultsService.swift
//  IbiProductStore
//
//  Created by Claude Code on 15/08/2025.
//

import Foundation
import UIKit

final class UserDefaultsService {
    
    static let shared = UserDefaultsService()
    
    // MARK: - Keys
    private enum Keys {
        static let isDarkMode = "isDarkMode"
        static let language = "selectedLanguage"
    }
    
    // MARK: - Dark Mode
    var isDarkMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isDarkMode)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isDarkMode)
            applyDarkMode(newValue)
        }
    }
    
    // MARK: - Language
    var selectedLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.language) ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.language)
            applyLanguage(newValue)
        }
    }
    
    // MARK: - Apply Settings
    private func applyDarkMode(_ isDark: Bool) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
        }
    }
    
    private func applyLanguage(_ language: String) {
        NotificationCenter.default.post(name: .languageChanged, object: language)
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}