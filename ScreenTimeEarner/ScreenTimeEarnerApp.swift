//
//  ScreenTimeEarnerApp.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/6/23.
//

import SwiftUI

@main
struct ScreenTimeEarnerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
