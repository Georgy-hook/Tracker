//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Georgy on 10.09.2023.
//

import CoreData
import UIKit

enum TrackerRecordStoreError: Error{
    case decodingErrorInvalidID
    case decodingErrorInvalidDate
    case deletingError
}
struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerRecordStoreDelegate: AnyObject{
    func store(
        _ store: TrackerRecordStore
    )
}

final class TrackerRecordStore: NSObject{
    
    // MARK: - Variables
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    private let trackerStore = TrackerStore()
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var completedTrackers: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let completedTrackers = try? objects.map({ try self.makeRecord(from: $0) })
        else { return [] }
        return completedTrackers
    }
    
    // MARK: - Initialization
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
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
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
    
    // MARK: - Set methods
    func addNewRecord(_ record:TrackerRecord) throws{
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateTracker(trackerRecordCoreData, with: record)
        try context.save()
        try fetchedResultsController?.performFetch()
    }
    
    func updateTracker(_ trackerRecordCoreData: TrackerRecordCoreData, with record:TrackerRecord) {
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.recordID = record.recordID
    }
    
    func removeRecord(for uuid: UUID, with date: Date) throws {
        
        guard let fetchedResultsController = fetchedResultsController,
              let objects = fetchedResultsController.fetchedObjects else {
            return
        }
        
        if let recordToDelete = objects.first(where: {
            $0.recordID == uuid &&
            Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date)
        }){
            context.delete(recordToDelete)
            try context.save()
            try fetchedResultsController.performFetch()
        } else {
            throw TrackerRecordStoreError.deletingError
        }
    }
    
    
    //MARK: - Get methods
    
    func makeRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord{
        guard let id = trackerRecordCoreData.recordID else {
            throw TrackerRecordStoreError.decodingErrorInvalidID
        }
        guard let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidDate
        }
        
        return TrackerRecord(recordID: id, date: date)
    }
    
    func getCompletedID(with currentDate:Date) -> Set<UUID>{
        var completedID: Set<UUID> = []
        completedTrackers.forEach({
            if Calendar.current.isDate($0.date, inSameDayAs: currentDate){
                completedID.insert($0.recordID)
            }
        })
        return completedID
    }
    
    func countRecords(forUUID uuid: UUID) -> Int {
        guard let fetchedResultsController = fetchedResultsController,
              let objects = fetchedResultsController.fetchedObjects else {
            return 0
        }

        let predicate = NSPredicate(format: "recordID == %@", uuid as CVarArg)

        let filteredObjects = objects.filter { predicate.evaluate(with: $0) }

        return filteredObjects.count
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore:NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(self)
    }
}

