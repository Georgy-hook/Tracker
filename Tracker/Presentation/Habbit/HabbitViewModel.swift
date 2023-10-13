//
//  HabbitViewModel.swift
//  Tracker
//
//  Created by Georgy on 01.10.2023.
//

import Foundation

final class HabbitViewModel{
    @Observable
    private(set) var completed:Bool = false
    
    private let tempStorage = TempStorage.shared
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let mode: HabbitViewControllerMode
    
    init(mode:HabbitViewControllerMode) {
        self.mode = mode
        do {
            switch mode {
            case .create:
                tempStorage.setID(UUID())
            case .edit(let ID):
                let id = ID.uuidString
                let tracker = try trackerStore.getTracker(by: id)
                tempStorage.setTracker(tracker)
            }
        } catch {
            print(error)
        }
    }
    
    func setEmoji(_ emoji:String){
        tempStorage.setEmoji(emoji)
    }
    
    func setColor(_ color:String){
        tempStorage.setColor(color)
    }
    
    func setName(_ name:String){
        tempStorage.setName(name)
    }
    
    func setSchedule(_ schedule:[Int]){
        tempStorage.setSchedule(schedule)
    }
    
    func getCategory() -> String{
        return tempStorage.getCategory() ?? ""
    }
    
    func getShedule() -> [Int]{
        return tempStorage.getShedule() ?? []
    }
    
    func shouldUpdateUI(){
        let trackerIsComplete = tempStorage.buildTracker() != nil
        completed = trackerIsComplete ? true : false
    }
    
    func addTracker(){
        guard let tracker = tempStorage.buildTracker() else { return }
        guard let title = tempStorage.getCategory() else { return }
        
        trackerCategoryStore.addTracker(tracker, toCategoryWithTitle: title)
    }
}
