//
//  Store.swift
//  Tracker
//
//  Created by bot on 29.07.2026.
//

import CoreData

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        controller.delegate = delegate
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("❌ Failed to perform fetch in TrackerStore: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func createTracker(
        name: String,
        emoji: String,
        colorHex: String,
        scheduleDays: String,
        category: TrackerCategoryCoreData
    ) -> TrackerCoreData? {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else {
            return nil
        }
        let tracker = TrackerCoreData(entity: entity, insertInto: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.emoji = emoji
        tracker.colorHex = colorHex
        tracker.scheduleDays = scheduleDays
        tracker.category = category
        saveContext()
        return tracker
    }
    
    func fetchTrackers() -> [TrackerCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchTrackers(for category: TrackerCategoryCoreData) -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch trackers for category: \(error)")
            return []
        }
    }
    
    func fetchTracker(by id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to fetch tracker by id: \(error)")
            return nil
        }
    }
    
    func fetchTrackers(by name: String) -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch trackers by name: \(error)")
            return []
        }
    }
    
    func fetchTrackers(for weekday: Int) -> [TrackerCoreData] {
        let allTrackers = fetchTrackers()
        return allTrackers.filter { tracker in
            guard let scheduleDays = tracker.scheduleDays else { return false }
            let days = scheduleDays.split(separator: ",").compactMap { Int($0) }
            return days.contains(weekday)
        }
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }
    
    func updateTracker(_ tracker: TrackerCoreData, name: String, emoji: String, colorHex: String, scheduleDays: String) {
        tracker.name = name
        tracker.emoji = emoji
        tracker.colorHex = colorHex
        tracker.scheduleDays = scheduleDays
        saveContext()
    }
    
    func countTrackers() -> Int {
        return fetchTrackers().count
    }
    
    // MARK: - Fetched Results Controller Helpers
    
    func numberOfSections() -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData? {
        return fetchedResultsController?.object(at: indexPath)
    }
    
    func sectionTitle(at section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    func refresh() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("❌ Failed to refresh fetch: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = delegate
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("❌ Failed to perform fetch in TrackerCategoryStore: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func createCategory(title: String) -> TrackerCategoryCoreData? {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            return nil
        }
        let category = TrackerCategoryCoreData(entity: entity, insertInto: context)
        category.id = UUID()
        category.title = title
        saveContext()
        return category
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchCategory(by title: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to fetch category by title: \(error)")
            return nil
        }
    }
    
    func fetchCategory(by id: UUID) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to fetch category by id: \(error)")
            return nil
        }
    }
    
    func updateCategory(_ category: TrackerCategoryCoreData, title: String) {
        category.title = title
        saveContext()
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) {
        context.delete(category)
        saveContext()
    }
    
    func fetchCategoriesWithTrackers() -> [(category: TrackerCategoryCoreData, trackers: [TrackerCoreData])] {
        let categories = fetchCategories()
        var result: [(category: TrackerCategoryCoreData, trackers: [TrackerCoreData])] = []
        
        for category in categories {
            let trackers = category.trackers?.allObjects as? [TrackerCoreData] ?? []
            if !trackers.isEmpty {
                result.append((category: category, trackers: trackers))
            }
        }
        
        return result
    }
    
    func countCategories() -> Int {
        return fetchCategories().count
    }
    
    // MARK: - Fetched Results Controller Helpers
    
    func numberOfSections() -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        return fetchedResultsController?.object(at: indexPath)
    }
    
    func refresh() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("❌ Failed to refresh fetch: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
}

// MARK: - TrackerRecordStore
final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "trackerId", ascending: true),
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "trackerId",
            cacheName: nil
        )
        
        controller.delegate = delegate
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("❌ Failed to perform fetch in TrackerRecordStore: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func createRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData? {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCoreData", in: context) else {
            return nil
        }
        let record = TrackerRecordCoreData(entity: entity, insertInto: context)
        record.id = UUID()
        record.trackerId = trackerId
        record.date = date
        saveContext()
        return record
    }
    
    func fetchRecords() -> [TrackerRecordCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchRecords(for trackerId: UUID) -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch records for tracker: \(error)")
            return []
        }
    }
    
    func fetchRecords(on date: Date) -> [TrackerRecordCoreData] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch records on date: \(error)")
            return []
        }
    }
    
    func fetchRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to fetch record: \(error)")
            return nil
        }
    }
    
    func isTrackerCompleted(trackerId: UUID, on date: Date) -> Bool {
        return fetchRecord(trackerId: trackerId, date: date) != nil
    }
    
    func deleteRecord(_ record: TrackerRecordCoreData) {
        context.delete(record)
        saveContext()
    }
    
    func deleteRecord(trackerId: UUID, date: Date) {
        guard let record = fetchRecord(trackerId: trackerId, date: date) else { return }
        deleteRecord(record)
    }
    
    func countRecords(for trackerId: UUID) -> Int {
        return fetchRecords(for: trackerId).count
    }
    
    func countRecords() -> Int {
        return fetchRecords().count
    }
    
    func countRecords(on date: Date) -> Int {
        return fetchRecords(on: date).count
    }
    
    // MARK: - Fetched Results Controller Helpers
    
    func numberOfSections() -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerRecordCoreData? {
        return fetchedResultsController?.object(at: indexPath)
    }
    
    func refresh() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("❌ Failed to refresh fetch: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
}
