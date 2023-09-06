//
//  DateFormatter.swift
//  Tracker
//
//  Created by Georgy on 05.09.2023.
//

import UIKit
class AppDateFormatter {
    static let shared = AppDateFormatter()
    
    private init() {}
    
    private lazy var dateFormatterToString: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private lazy var dateFormatterToDays: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func dateToString(with date:Date?) -> String{
        guard let date = date else {return ""}
        return dateFormatterToString.string(from: date)
    }
    
    func dateToDays(with date:Date) -> String{
        return dateFormatterToDays.string(from: date).capitalized
    }
}
