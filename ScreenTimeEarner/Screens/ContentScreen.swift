//
//  ContentView.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/6/23.
//

import CloudKit
import CoreData
import SwiftUI

struct ContentScreen: View {
    @EnvironmentObject var persistenceController: PersistenceController
    
    let child: Child
    
    @State var showChildEntry = false
    @State var showShareSheet = false
    @State var share: CKShare?
    
    var body: some View {
        TabView {
            TimerView(child: child)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
            
            ActivityList(child: child)
                .tabItem {
                    Image(systemName: "clock")
                    Text("Activity History")
                }
        }
        .navigationTitle(child.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await createShare(child)
                        showShareSheet = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet, content: {
            if let share = share {
                CloudSharingView(share: share, container: persistenceController.ckContainer, child: child)
            } else {
                ProgressView()
            }
        })
    }
    
    func createShare(_ child: Child) async {
        do {
            let (_, share, _) = try await persistenceController.container.share([child], to: nil)
            share[CKShare.SystemFieldKey.title] = child.displayName
            self.share = share
        } catch {
            print("Failed to create share")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentScreen(child: Child().example).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
