//
//  Array + Equatable.swift
//  Tracker
//
//  Created by Georgy on 29.09.2023.
//

import Foundation

extension Array where Element: Hashable {
    func diff(from other: [Element]) -> (inserts: [Element], deletes: [Element], reloads: [Element]) {
        let oldSet = Set(self)
        let newSet = Set(other)

        let deletes = Array(oldSet.subtracting(newSet))
        let inserts = Array(newSet.subtracting(oldSet))

        // Find elements that are both in the old and new arrays (potential updates)
        let potentialUpdates = Array(oldSet.intersection(newSet))
        
        // Find elements that have changed (actual updates)
        let reloads = potentialUpdates.filter { element in
            return self.firstIndex(of: element) != other.firstIndex(of: element)
        }

        return (inserts, deletes, reloads)
    }
}


