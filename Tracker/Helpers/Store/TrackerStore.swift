//
//  TrackerStore.swift
//  Tracker
//
//  Created by Georgy on 10.09.2023.
//

import CoreData
import UIKit

enum TrackerStoreError: Error{
    case decodingErrorInvalidID
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidShedule
    case decodingErrorInvalidCategory
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject{
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject{
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    weak var delegate: TrackerStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
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
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
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
    
    var trackers: [TrackerCategory] {
        guard let objects = self.fetchedResultsController?.fetchedObjects,
              let trackers = try? makeCategory(from: objects)
        else { return [] }
        return trackers
    }
    
    func addNewTracker(_ tracker:Tracker) throws -> TrackerCoreData{
        let trackerCoreData = TrackerCoreData(context: context)
        updateTracker(trackerCoreData, with: tracker)
        try context.save()
        return trackerCoreData
    }
    
    func updateTracker(_ trackerCoreData:TrackerCoreData, with tracker:Tracker){
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        
    }
    
    func makeTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker{
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let shedule = trackerCoreData.schedule as? [Int] else {
            throw TrackerStoreError.decodingErrorInvalidShedule
        }
        
        return(Tracker(id: id,
                       name: name,
                       color: color,
                       emoji: emoji,
                       schedule: shedule))
    }
    
    func makeCategory(from trackerCoreDataObjects: [TrackerCoreData]) throws -> [TrackerCategory] {
        var trackerCategoryDict = [String: [Tracker]]()
        
        for trackerCoreData in trackerCoreDataObjects {
            do {
                let tracker = try makeTracker(from: trackerCoreData)
                if let categoryTitle = trackerCoreData.category?.title {
                    if var trackersForCategory = trackerCategoryDict[categoryTitle] {
                        trackersForCategory.append(tracker)
                        trackerCategoryDict[categoryTitle] = trackersForCategory
                    } else {
                        trackerCategoryDict[categoryTitle] = [tracker]
                    }
                }
            } catch {
                throw TrackerStoreError.decodingErrorInvalidCategory
            }
        }

        let trackerCategories = trackerCategoryDict.map { (title, trackers) in
            return TrackerCategory(title: title, trackers: trackers)
        }
        
        return trackerCategories
    }
    
    func isEmpty() -> Bool {
        guard let objects = self.fetchedResultsController?.fetchedObjects else {
            return true
        }
        return objects.isEmpty
    }
}

extension TrackerStore:NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
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
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}

