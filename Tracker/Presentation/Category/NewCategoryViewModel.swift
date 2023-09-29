//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Georgy on 28.09.2023.
//

import Foundation

final class NewCategoryViewModel{
    private let trackerCategoryStore = TrackerCategoryStore()
    
    func shouldUpdateCategoryStore(with categoryName: String, mode: CategoryViewControllerMode){
        do {
            switch mode {
            case .create:
                try trackerCategoryStore.createCategory(withTitle: categoryName)
            case .edit(let oldCategoryName):
                try trackerCategoryStore.updateCategory(oldTitle: oldCategoryName, newTitle: categoryName)
            }
        } catch {
            print(error)
        }
    }
     
}
