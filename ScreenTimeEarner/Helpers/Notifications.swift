//
//  Notifications.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import Foundation
import SwiftUI

class Notifications: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    // Since Its NSObject
    override init() {
        super.init()
        self.authorizeNotification()
    }
    
    // MARK: Requesting Notification Access
    func authorizeNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { _, _ in
        }
        
        // MARK: To Show In App Notification
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound,.banner])
    }
    
    func addNotification(timeRemaining: Double, selectedTimerType: ActivityType) {
        var message: String
        
        switch selectedTimerType {
        case .activity, .exercise:
            message = "Great job! You have earned more Screen Time"
        case .screenTime:
            message = "You have used all of you Screen Time. You need to earn more to continue."
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(selectedTimerType.rawValue) Timer"
        content.subtitle = message
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "1", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining), repeats: false))
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["1"])
    }
}
