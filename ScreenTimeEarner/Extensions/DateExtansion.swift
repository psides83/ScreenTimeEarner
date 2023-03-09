//
//  DateExtansions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

//MARK: - Date
extension Date {
    var yearInt: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return Int(formatter.string(from: self)) ?? 2022
    }
    
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: self)
    }
    
    var monthInt: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: self).int
    }
    
    var monthAbriviated: String {
        let format = DateFormatter()
        format.dateFormat = "MMM"
        return format.string(from: self)
    }
    
    var yearAndMonth: String {
        let format = DateFormatter()
        format.dateFormat = "yyyyMM"
        return format.string(from: self)
    }
    
    var ddMMMyyyy: String {
        let format = DateFormatter()
        format.dateFormat = "dd-MMM-yyyy"
        return format.string(from: self)
    }
    
    var timestamp: String {
        let format = DateFormatter()
        format.dateFormat = "dd-MMM-yyyy hh:mma"
        return format.string(from: self)
    }
    
    var id: String {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddhhmmss"
        return format.string(from: self)
    }
    
    var medium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }
    
    var dateOnly: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        //        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
