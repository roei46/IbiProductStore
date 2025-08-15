//
//  DetailsProtocol.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import Foundation
import Combine

protocol DetailsProtocol: ObservableObject {
    var title: String { get }
    var subtitle: String? { get }
    var price: String? { get }
    var description: String { get }
    var imageUrls: [String] { get }
    var isFavorite: Bool { get }
    
    // Edit state management
    var isEditing: Bool { get }
    
    // Editable properties
    var editableTitle: String { get set }
    var editablePrice: String { get set }
    var editableDescription: String { get set }
    
    // Published property publishers
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    var isEditingPublisher: AnyPublisher<Bool, Never> { get }
    var editableTitlePublisher: AnyPublisher<String, Never> { get }
    var editablePricePublisher: AnyPublisher<String, Never> { get }
    var editableDescriptionPublisher: AnyPublisher<String, Never> { get }
    
    // Triggers (like LoginViewModel pattern)
    var closeTrigger: PassthroughSubject<Void, Never> { get }
    
    func toggleFavorite()
    func shareContent() -> String
    func edit()
    func saveChanges()
    func cancelEditing()
}
