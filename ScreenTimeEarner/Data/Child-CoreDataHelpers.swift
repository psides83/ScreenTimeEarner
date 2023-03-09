//
//  Child-CoreDataHelpers.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import Foundation

extension Child {
    var displayName: String {
        name?.capitalized ?? "No User"
    }
    
    var childTimeEvents: [TimeEvent] {
        timeEvents?.allObjects as? [TimeEvent] ?? []
    }
    
    var availableScreenTime: Double {
        let earnedTime = childTimeEvents.reduce(0) { $0 + $1.timeEarned }
        let spentTime = childTimeEvents.reduce(0) { $0 + $1.timeSpent }
        
        return earnedTime - spentTime
    }
    
    var defaultActivityTimer: ActivityTimer {
        let timer = ActivityTimer(context: PersistenceController.shared.container.viewContext)
        timer.id = UUID()
        timer.status = "idle"
        timer.child = self
        timer.total = 1800.0
        timer.amount = 1800.0
        timer.progress = 1.0
        
        return timer
    }
    
    var defaultExerciseTimer: ExerciseTimer {
        let timer = ExerciseTimer(context: PersistenceController.shared.container.viewContext)
        timer.id = UUID()
        timer.status = "idle"
        timer.child = self
        timer.total = 600.0
        timer.amount = 600.0
        timer.progress = 1.0
        
        return timer
    }
    
    var defaultScreenTimeTimer: ScreenTimeTimer {
        let timer = ScreenTimeTimer(context: PersistenceController.shared.container.viewContext)
        timer.id = UUID()
        timer.status = "idle"
        timer.child = self
        timer.total = 0.0
        timer.amount = 0.0
        timer.progress = 0.0
        
        return timer
    }
    
    var example: Child {
        let child = Child(context: PersistenceController.shared.container.viewContext)
        child.id = UUID()
        child.name = "Jake Sides"
        
        return child
    }
}
