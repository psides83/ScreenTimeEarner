//
//  ActivityList.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import SwiftUI

struct ActivityList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let child: Child
    
    @FetchRequest var timeEvents: FetchedResults<TimeEvent>

    init(child: Child) {
        self.child = child
        
        _timeEvents = FetchRequest<TimeEvent>(
            entity: TimeEvent.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \TimeEvent.timestamp,
                    ascending: true
                )
            ],
            predicate: NSPredicate(format: "child == %@", child))
    }
    
    var body: some View {
        VStack {
            Text("Screen Time Available: \(child.availableScreenTime.time)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            List {
                Section(header: Text("Earned Time")) {
                    ForEach(timeEvents.filter({ !$0.awarded })) { event in
                        ActivityCell(earning: event)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    delete(event)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    issue(event)
                                } label: {
                                    Label("Issue", systemImage: "hourglass.badge.plus")
                                }
                                .tint(.mint)
                            }
                    }
                }
                
                Section(header: Text("Issued Time")) {
                    ForEach(timeEvents.filter({ $0.awarded })) { event in
                        SpentCellView(spent: event)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    delete(event)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func issue(_ event: TimeEvent) {
        withAnimation {
            event.child?.objectWillChange.send()
            
            event.awarded = true
            event.dateAwarded = Date()
            event.timeSpent = 1800.0
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func delete(_ object: TimeEvent) {
        withAnimation {
            viewContext.delete(object)
        }
    }
}

struct ActivityList_Previews: PreviewProvider {
    static var previews: some View {
        ContentScreen(child: Child().example).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct SpentCellView: View {
    
    let spent: TimeEvent
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Time Awared")
            
            Text(spent.dateAwarded?.medium ?? "")
                .font(.caption)
        }
    }
}
