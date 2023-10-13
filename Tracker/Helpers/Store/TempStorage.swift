//
//  TempStorage.swift
//  Tracker
//
//  Created by Georgy on 30.08.2023.
//

import Foundation

class TempStorage {
    static let shared = TempStorage()
    
    struct TempTracker {
        var id: UUID?
        var name: String?
        var color: String?
        var emoji: String?
        var schedule: [Int]?
        var category: String?
        
        var isComplete: Bool {
            guard id != nil && name != nil && color != nil && emoji != nil && schedule != nil && category != nil else { return false }
            guard name != "" && color != "" && emoji != "" && schedule != [] && category != "" else { return false }
            
            return true
        }
    }
    private var tempTracker: TempTracker = TempTracker()
    
    private init() {}
    
    func setTracker(_ tracker: Tracker?) {
        guard let tracker = tracker else { return }
        tempTracker.id = tracker.id
        tempTracker.name = tracker.name
        tempTracker.color = tracker.color
        tempTracker.emoji = tracker.emoji
        tempTracker.schedule = tracker.schedule
    }
    
    func setID(_ id: UUID) {
        tempTracker.id = id
    }
    
    func setName(_ name: String) {
        tempTracker.name = name
    }
    
    func setColor(_ color: String) {
        tempTracker.color = color
    }
    
    func setEmoji(_ emoji: String) {
        tempTracker.emoji = emoji
    }
    
    func setSchedule(_ schedule: [Int]) {
        tempTracker.schedule = schedule
    }
    
    func setCategory(_ category: String) {
        tempTracker.category = category
    }
    
    func getShedule() -> [Int]?{
        guard let shedule = tempTracker.schedule else { return nil }
        return shedule
    }
    
    func getCategory() -> String?{
        guard let category = tempTracker.category else { return nil }
        
        return category
    }
    
    func buildTracker() -> Tracker? {
        guard tempTracker.isComplete else { return nil }
        
        return Tracker(
            id: tempTracker.id!,
            name: tempTracker.name!,
            color: tempTracker.color!,
            emoji: tempTracker.emoji!,
            schedule: tempTracker.schedule!
        )
    }
    
    func resetTempTracker() {
        tempTracker = TempTracker()
    }
}
