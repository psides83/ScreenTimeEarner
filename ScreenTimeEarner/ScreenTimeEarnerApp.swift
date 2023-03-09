//
//  ScreenTimeEarnerApp.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/6/23.
//

import SwiftUI

@main
struct ScreenTimeEarnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ChildSelectScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
        }
    }
}
