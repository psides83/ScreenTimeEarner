//
//  Exercisetimer-CoreDataHelpers.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/8/23.
//

import Foundation

extension ExerciseTimer {
    var uuid: UUID {
        return id ?? UUID()
    }
    
    var statusDisplay: TimerStatus {
        let unwrapped = status ?? "idle"
        return TimerStatus(rawValue: unwrapped) ?? .idle
    }
    
    var amountDisplay: Double {
        amount
    }
    
    var totalDisplay: Double {
        total
    }
}
