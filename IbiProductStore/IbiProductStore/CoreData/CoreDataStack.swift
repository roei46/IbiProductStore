//
//  CoreDataStack.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "IbiProductStore")
        guard let description = container.persistentStoreDescriptions.first else {
              print("Warning: No persistent store descriptions found.")
              return container
          }
                
        guard let storeURL = description.url else { return container }
        
        description.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        container.loadPersistentStores { storeDescription, error in
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
    init() {}
    
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
