//
//  TrackerModel.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [Int]
    
    func getDays() -> [String]{
        let weekdays = self.schedule
        let weekdaysArray = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
        var formattedWeekdays: [String] = []
        
        for index in weekdays {
            if index >= 0 && index < weekdaysArray.count {
                formattedWeekdays.append(weekdaysArray[index])
            }
        }
        
        return formattedWeekdays
    }
    
    func daysUntilNextScheduledDay(currentDay: Int) -> Int {
        let nextScheduledDay = schedule.first(where: { $0 >= currentDay }) ?? schedule.first
        if let nextScheduledDay = nextScheduledDay {
            let daysUntilNextDay = nextScheduledDay - currentDay
            guard daysUntilNextDay >= 0 else { return daysUntilNextDay + 7 }
            return daysUntilNextDay
        } else {
            return -1
        }
    }
}
