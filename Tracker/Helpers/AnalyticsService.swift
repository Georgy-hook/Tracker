//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Georgy on 08.10.2023.
//

import Foundation
import YandexMobileMetrica

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
    // Другие экраны, если они есть
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "322d109b-550a-4a77-813c-ee65e320327a") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        var params: [String: Any] = ["event": event.rawValue, "screen": screen.rawValue]
        
        if let item = item {
            params["item"] = item.rawValue
        }
        
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
    }
}
