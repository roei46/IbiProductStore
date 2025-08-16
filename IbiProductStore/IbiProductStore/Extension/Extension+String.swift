//
//  Extension+String.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 16/08/2025.
//

import Foundation

extension String {
    var localized: String {
        return LocalizationHelper.localizedString(for: self)
    }
}
