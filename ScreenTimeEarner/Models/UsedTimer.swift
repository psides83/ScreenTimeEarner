//
//  UsedTimer.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/8/23.
//

import Foundation

struct UsedTimer: Identifiable, Equatable {
    let id: UUID?
    var status: TimerStatus?
    var backgroundTime: Date?
    var amount: Double?
    var total: Double?
    var progress: Double?
}
