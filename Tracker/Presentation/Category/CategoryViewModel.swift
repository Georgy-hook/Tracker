//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Georgy on 25.09.2023.
//

import Foundation

enum CategoryChange {
    case insert(IndexPath)
    case delete(IndexPath)
}

final class CategoryViewModel{
    @Observable
    private(set) var categories:[String] = []
    
    private var oldCategories:[String] = []
    private(set) var changes: [CategoryChange] = []
    private let trackerCategoryStore = TrackerCategoryStore()
    private let tempStorage = TempStorage.shared
    
    init() {
        self.categories = trackerCategoryStore.trackersCategories.map{ $0.title }
        trackerCategoryStore.delegate = self
    }
    
    func deleteCategory(at category: String){
        do{
            try trackerCategoryStore.deleteObject(at: category)
        } catch{
            print(error)
        }
    }
    
    func getCountOfCategories() -> Int{
        return categories.count
    }
    
    func setCategory(named category: String){
        tempStorage.setCategory(category)
    } 
    
    func shouldUpdatePlaceholder() -> Bool{
        return !trackerCategoryStore.isEmpty()
    }
    
    func isCategorySelected(_ category: String) -> Bool{
        return tempStorage.getCategory() == category
    }
    
    func calculateChanges(){
        changes = []
        
        let oldSet = Set(oldCategories)
        let newSet = Set(categories)

        for (index, category) in oldCategories.enumerated() {
            if !newSet.contains(category) {
                changes.append(.delete(IndexPath(row: index, section: 0)))
            }
        }

        for (index, category) in categories.enumerated() {
            if !oldSet.contains(category) {
                changes.append(.insert(IndexPath(row: index, section: 0)))
            }
        }
    }
}

extension CategoryViewModel:TrackerCategoryStoreDelegate{
    func store(_ store: TrackerCategoryStore) {
        oldCategories = categories
        categories = store.trackersCategories.map{ $0.title }
    }
}
