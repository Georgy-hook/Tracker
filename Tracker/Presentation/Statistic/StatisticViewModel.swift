//
//  StatisticViewModel.swift
//  Tracker
//
//  Created by Georgy on 10.10.2023.
//

import Foundation

struct StatisticsElement{
    let description: String
    let value: Int
}

final class StatisticViewModel{
    @Observable
    var StatisticsModel: [StatisticsElement] = []
    
    @Observable
    private(set) var currentState: PlaceholderState = .noData
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let dateFormatter = AppDateFormatter.shared
    
    init(){
        trackerRecordStore.delegate = self
    }
    
    private func maxContinuousDays(with sortedRecords: [TrackerRecord]) -> Int {
        var maxDays = 0
        var currentDays = 0
        let calendar = Calendar.current
        
        for i in 1..<sortedRecords.count {
            let currentDate = sortedRecords[i].date
            let previousDate = sortedRecords[i - 1].date
            
            guard calendar.numberOfDaysBetween(previousDate, and: currentDate) != 0 else { continue }
            if calendar.numberOfDaysBetween(previousDate, and: currentDate) == 1 {
                currentDays += 1
            }else{
                currentDays = 0
            }
            
            maxDays = max(maxDays, currentDays)
        }
        
        return maxDays
    }
    
    private func getCountOfTrackers(forDate date: Date) -> Int{
        let dayOfWeek = dateFormatter.dayOfWeekInt(for: date)
        do{
            try trackerStore.fetchRelevantTrackers(forDay: dayOfWeek)
            var countOfTrackers = 0
            trackerStore.trackers.forEach{
                countOfTrackers += $0.trackers.count
            }
            return countOfTrackers
            
        }catch{
            return 0
        }
    }
    
    private func getPerfectDays(with sortedRecords: [TrackerRecord]) -> Int{
        var perfectDays = 0
        var currentDays = 1
        let calendar = Calendar.current
        
        for i in 1..<sortedRecords.count {
            let currentDate = sortedRecords[i].date
            let previousDate = sortedRecords[i - 1].date
            
            if calendar.numberOfDaysBetween(currentDate, and: previousDate) == 0 {
                currentDays += 1
            } else {
                if currentDays == getCountOfTrackers(forDate: previousDate) { perfectDays += 1 }
                currentDays = 1
                
            }
            
        }
        
        guard let lastDate = sortedRecords.last?.date else { return perfectDays}
        if currentDays == getCountOfTrackers(forDate: lastDate) { perfectDays += 1 }
        
        return perfectDays
    }
    
    private func getCountOfCompletedTrackers() -> Int{
        return trackerRecordStore.completedTrackers.count
    }
    
    private func getAverageCompletedTrackersPerDay(with sortedRecords: [TrackerRecord]) -> Int{
        var countPerDay:[Int] = []
        var countForCurrentDay = 1
        let calendar = Calendar.current
        
        for i in 1..<sortedRecords.count {
            let currentDate = sortedRecords[i].date
            let previousDate = sortedRecords[i - 1].date
            
            if calendar.numberOfDaysBetween(currentDate, and: previousDate) == 0 {
                countForCurrentDay += 1
            } else {
                countPerDay.append(countForCurrentDay)
                countForCurrentDay = 1
            }
            
        }
        countPerDay.append(countForCurrentDay)
        return countPerDay.reduce(0, +) / countPerDay.count
    }
    
    private func areAllElementsZero(in statistics: [StatisticsElement]) -> Bool {
        return statistics.allSatisfy { $0.value == 0 }
    }
    
    private func getStatistics(with sortedRecords: [TrackerRecord]){
        let bestPeriod = StatisticsElement(description: NSLocalizedString("Best period", comment: ""),
                                           value: maxContinuousDays(with: sortedRecords))
        let perfectDays = StatisticsElement(description: NSLocalizedString("Perfect days", comment: ""),
                                            value: getPerfectDays(with: sortedRecords))
        let countOfCompletedTrackers = StatisticsElement(description: NSLocalizedString("Trackers completed", comment: ""),
                                                         value: getCountOfCompletedTrackers())
        let averageCompletedTrackers = StatisticsElement(description: NSLocalizedString("Average value", comment: ""),
                                                         value: getAverageCompletedTrackersPerDay(with: sortedRecords))
        
        let statistics = [bestPeriod,perfectDays,countOfCompletedTrackers,averageCompletedTrackers]
        
        if areAllElementsZero(in: statistics) {
            currentState = .noData
        } else {
            StatisticsModel = statistics
            currentState = .hide
        }
    }
    
    func initial(){
        guard !trackerRecordStore.completedTrackers.isEmpty else {
            currentState = .noData
            return
        }
        
        let sortedRecords = trackerRecordStore.completedTrackers.sorted { $0.date < $1.date }
        
        getStatistics(with: sortedRecords)
    }
}

extension StatisticViewModel: TrackerRecordStoreDelegate{
    func store(_ store: TrackerRecordStore) {
        guard !store.completedTrackers.isEmpty else {
            return
        }
        
        let sortedRecords = store.completedTrackers.sorted { $0.date < $1.date }
        
        getStatistics(with: sortedRecords)
    }
}
