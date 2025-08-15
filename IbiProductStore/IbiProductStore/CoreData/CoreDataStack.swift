//
//  CoreDataStack.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData
import CryptoKit

final class CoreDataStack {
    
    // MARK: - Singleton
    static let shared = CoreDataStack()
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "IbiProductStore")
        
        // Configure for encryption at file system level
        let description = container.persistentStoreDescriptions.first
        description?.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        
        // Enable data protection
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    private init() {
        // Encryption now handled directly in CoreDataStorageService
    }
    
    // MARK: - Core Data Operations
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }
}
    
//    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
//        return try await withCheckedThrowingContinuation { continuation in
//            persistentContainer.performBackgroundTask { context in
//                do {
//                    let result = try block(context)
//                    try context.save()
//                    continuation.resume(returning: result)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//    
//    // MARK: - Data Protection
//    // Core Data handles encryption through FileProtectionType.complete
//    // All data is automatically encrypted when device is locked
//    
//    // MARK: - Reset
//    func resetCoreData() {
//        let coordinator = persistentContainer.persistentStoreCoordinator
//        
//        for store in coordinator.persistentStores {
//            do {
//                try coordinator.remove(store)
//                if let url = store.url {
//                    try FileManager.default.removeItem(at: url)
//                }
//            } catch {
//                print("Error resetting Core Data: \(error)")
//            }
//        }
//        
//        // Reload the persistent store
//        persistentContainer.loadPersistentStores { _, error in
//            if let error = error {
//                print("Error reloading Core Data: \(error)")
//            }
//        }
//    }
//}
