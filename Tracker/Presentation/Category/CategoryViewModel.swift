//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Georgy on 25.09.2023.
//

import Foundation

final class CategoryViewModel{
    @Observable
    private(set) var categories:[String] = []
    
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
}

extension CategoryViewModel:TrackerCategoryStoreDelegate{
    func store(_ store: TrackerCategoryStore) {
        categories = store.trackersCategories.map{ $0.title }
    }
}
