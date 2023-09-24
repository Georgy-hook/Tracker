//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Georgy on 10.09.2023.
//
import CoreData
import UIKit

enum TrackerCategoryStoreError: Error{
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTracker
}

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerCategoryStoreDelegate: AnyObject{
    func store(
        _ store: TrackerCategoryStore,
        didUpdate update: TrackerCategoryStoreUpdate
    )
}

final class TrackerCategoryStore: NSObject{
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private let trackerStore = TrackerStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do { try self.init(context: context) }
        catch{
            fatalError("Init error")
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        self.fetchedResultsController = controller
        
        try controller.performFetch()
    }
    
    func getCategory(byTitle title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
            return nil
        }
    }

    var trackersCategories: [TrackerCategory]{
        guard let objects = self.fetchedResultsController?.fetchedObjects,
              let categories = try? objects.map({try self.makeCategory(from: $0)})
        else {return []}
        return categories
    }
    
    
    func createCategory(withTitle title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
    }
    
    func addTracker(_ tracker: Tracker, toCategoryWithTitle categoryTitle: String) {
        do {
            if let category = getCategory(byTitle: categoryTitle) {
                let trackerEntity = try trackerStore.addNewTracker(tracker)
                category.addToTracker(trackerEntity)
                try context.save()
            } else {
                print("Категория с названием '\(categoryTitle)' не найдена.")
            }
        } catch {
            print("Ошибка при добавлении трекера: \(error)")
        }
    }

    func makeCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        guard let trackerSet = trackerCategoryCoreData.tracker as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTracker
        }
        
        let trackers: [Tracker] = trackerSet.compactMap { trackerEntity in
            guard
                let id = trackerEntity.id,
                let name = trackerEntity.name,
                let color = trackerEntity.color,
                let emoji = trackerEntity.emoji,
                let schedule = trackerEntity.schedule as? [Int]
            else {
                return nil
            }
            
            return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    func isEmpty() -> Bool {
        guard let objects = self.fetchedResultsController?.fetchedObjects else {
            return true
        }
        return objects.isEmpty
    }
}

extension TrackerCategoryStore:NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.row)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.row)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.row)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.row, newIndex: newIndexPath.row))
        @unknown default:
            fatalError()
        }
    }
}


