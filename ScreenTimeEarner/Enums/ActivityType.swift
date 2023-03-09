//
//  RecordType.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/6/23.
//

import Foundation

enum ActivityType: String, CaseIterable, Identifiable {
    case activity = "Activity"
    case exercise = "Exercise"
    case screenTime = "Screen Time"
    
    var icon: String {
        switch self {
        case .activity: return "figure.soccer"
        case .exercise: return "figure.stairs"
        case .screenTime: return "hourglass.start"
        }
    }
    
    var id: String { rawValue }
}
