//
//  CoreDataError.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 16/08/2025.
//

import Foundation

struct CoreDataError: LocalizedError {
    let message: String
    let underlyingError: Error?
    
    init(_ message: String, underlyingError: Error? = nil) {
        self.message = message
        self.underlyingError = underlyingError
    }
    
    var errorDescription: String? {
        return "core_data_error".localized + ": \(message)"
    }
}