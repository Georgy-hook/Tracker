//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Georgy on 02.10.2023.
//

import Foundation

enum TrackerChange {
    case fix(IndexPath)
    case insert(IndexPath)
    case delete(IndexPath)
}

enum PlaceholderState{
    case noData
    case notFound
    case hide
}
final class TrackersViewModel{
    @Observable
    private(set) var trackers:[TrackerCategory] = []
    
    @Observable
    private(set) var currentState: PlaceholderState = .noData
    
    @Observable
    private(set) var currentDate: Date = Date()
    
    @Observable
    private(set) var completedID: Set<UUID> = []
    
    private(set) var changes: [TrackerChange] = []
    private let trackerStore = TrackerStore()
    private let dateFormatter = AppDateFormatter.shared
    private let trackerRecordStore = TrackerRecordStore()
    private let tempStorage = TempStorage.shared
    private let analyticsService = AnalyticsService()
    
    init() {
        trackerStore.delegate = self
    }
    
    func configure(){
        self.trackers = trackerStore.trackers
        self.currentState = trackerStore.isEmpty() ? .noData:.hide
        self.currentDate = Date()
        self.completedID = trackerRecordStore.getCompletedID(with: currentDate)
    }
    
    func searchRelevantTrackers(with searchText: String){
        let currentDay = dateFormatter.dayOfWeekInt(for: currentDate)
        do{
            try trackerStore.searchTrackers(with: searchText, forDay: currentDay)
            self.trackers = trackerStore.trackers
            currentState = trackerStore.isEmpty() ? .notFound:.hide
        }catch{
            print("Error searching for trackers: \(error)")
        }
    }
    
    func filterRelevantTrackers(for currentDate: Date){
        let currentDay = dateFormatter.dayOfWeekInt(for: currentDate)
        do {
            try trackerStore.fetchRelevantTrackers(forDay: currentDay)
            self.trackers = trackerStore.trackers
            currentState = trackerStore.isEmpty() ? .notFound:.hide
        }
        catch {
           print(error)
        }
    }
    
    func setCurrentDate(with date:Date){
        self.currentDate = date
        completedID = trackerRecordStore.getCompletedID(with: currentDate)
    }
    
    func resetTempTracker(){
        tempStorage.resetTempTracker()
    }

    func addCompletedTracker(_ tracker: Tracker) {
        let newRecord = TrackerRecord(recordID: tracker.id, date: currentDate)
        do{
            analyticsService.report(event: .click, screen: .main, item: .track)
            try trackerRecordStore.addNewRecord(newRecord)
        } catch{
            print("Error with completedTrackers: \(error)")
        }
    }
    
    func removeCompletedTracker(_ tracker: Tracker) {
        do {
            try trackerRecordStore.removeRecord(for: tracker.id, with: currentDate)
        } catch {
            print("No delete: \(error)")
        }
    }
    
    func countRecords(forUUID uuid: UUID) -> Int{
        return trackerRecordStore.countRecords(forUUID: uuid)
    }
    
    func editTracker(_ tracker: Tracker) {
        
    }
    
    func deleteTracker(_ tracker: Tracker) {
        do{
            try trackerStore.deleteObject(at: tracker.id)
            
        } catch{
            print(error)
        }
    }
    
    func pinTracker(_ tracker: Tracker) {
        
    }
}

extension TrackersViewModel:TrackerStoreDelegate{
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        self.trackers = store.trackers
    }
}
