//
//  DataStoreManager.swift
//  Tracker
//
//  Created by bot on 29.07.2026.
//

import Foundation
import CoreData

// MARK: - DataStoreManager
final class DataStoreManager: NSObject {
    private let context = PersistentContainer.shared.viewContext
    
    let trackerStore: TrackerStore
    let categoryStore: TrackerCategoryStore
    let recordStore: TrackerRecordStore
    
    static let shared = DataStoreManager()
    
    private override init() {
        self.trackerStore = TrackerStore(context: context)
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        
        super.init()
        
        // Настройка делегатов для автоматического обновления
        self.trackerStore.delegate = self
        self.categoryStore.delegate = self
        self.recordStore.delegate = self
    }
    
    func saveContext() {
        PersistentContainer.shared.saveContext()
    }
    
    func clearAllData() {
        let categories = categoryStore.fetchCategories()
        categories.forEach { categoryStore.deleteCategory($0) }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataStoreManager: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(name: .dataStoreWillChange, object: nil)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
    }
}

extension Notification.Name {
    static let dataStoreWillChange = Notification.Name("dataStoreWillChange")
    static let dataStoreDidChange = Notification.Name("dataStoreDidChange")
}
