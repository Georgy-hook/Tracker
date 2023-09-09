//
//  TrackerCategoryModel.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    func addedNewTracker(_ value:Tracker){
        TrackerCategory(title: title, trackers: trackers + [value])
    }
}

