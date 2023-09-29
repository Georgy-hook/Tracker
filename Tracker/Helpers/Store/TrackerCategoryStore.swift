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
    case deletingError
}

protocol TrackerCategoryStoreDelegate: AnyObject{
    func store(
        _ store: TrackerCategoryStore
    )
}

final class TrackerCategoryStore: NSObject{
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private let trackerStore = TrackerStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
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
    
    func updateCategory(oldTitle: String, newTitle: String) throws {
        guard let categoryToUpdate = getCategory(byTitle: oldTitle) else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        categoryToUpdate.title = newTitle
        
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
    
    func deleteObject(at category:String) throws{
        guard let fetchedResultsController = fetchedResultsController,
              let objects = fetchedResultsController.fetchedObjects else {
            return
        }
        
        if let objectToDelete = objects.first(where: {
            $0.title == category
        }){
            context.delete(objectToDelete)
            try context.save()
            try fetchedResultsController.performFetch()
        } else {
            throw TrackerCategoryStoreError.deletingError
        }
    }
}

extension TrackerCategoryStore:NSFetchedResultsControllerDelegate{

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self
            )
    }
}


