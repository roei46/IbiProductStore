//
//  LocalizationHelper.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation

final class LocalizationHelper {
    
    static func localizedString(for key: String) -> String {
        let language = UserDefaultsService.shared.selectedLanguage
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}
