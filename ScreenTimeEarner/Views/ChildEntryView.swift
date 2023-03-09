//
//  ChildEntryView.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import SwiftUI

struct ChildEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var showChildEntry: Bool
    
    @State var childName = ""
    @State var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add a user for the app")
            
            TextField("User Name", text: $childName)
                .textFieldStyle(.outlinedTextFieldStyle)
                .submitLabel(.done)
                .onSubmit {
                    save()
                }
            
            Text("Please enter a name to proceed.")
                .foregroundColor(showAlert ? .red : .clear)
                .animation(.easeInOut, value: showAlert)
                .onChange(of: childName) { newValue in
                    if newValue != "" {
                        showAlert = false
                    }
                }
            
            HStack {
                Spacer()
                
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(40)
        .tint(.mint)
    }
    
    func save() {
        guard childName != "" else {
            showAlert = true
            return
        }
        
        
        let newChild = Child(context: viewContext)
        newChild.id = UUID()
        newChild.timestamp = Date()
        newChild.name = childName
        
        let newActivityTimer = ActivityTimer(context: viewContext)
        newActivityTimer.id = UUID()
        newActivityTimer.child = newChild
        newActivityTimer.status = TimerStatus.idle.rawValue
        newActivityTimer.amount = 1800.0
        newActivityTimer.total = 1800.0
        newActivityTimer.progress = 1.0
        
        let newExerciseTimer = ExerciseTimer(context: viewContext)
        newExerciseTimer.id = UUID()
        newExerciseTimer.child = newChild
        newExerciseTimer.status = TimerStatus.idle.rawValue
        newExerciseTimer.amount = 600.0
        newExerciseTimer.total = 600.0
        newActivityTimer.progress = 1.0
        
        let newScreenTimeTimer = ScreenTimeTimer(context: viewContext)
        newScreenTimeTimer.id = UUID()
        newScreenTimeTimer.child = newChild
        newScreenTimeTimer.status = TimerStatus.idle.rawValue
        newScreenTimeTimer.amount = 1800.0
        newScreenTimeTimer.total = 1800.0
        newActivityTimer.progress = 1.0
        
        newChild.activityTimer = newActivityTimer
        newChild.exerciseTimer = newExerciseTimer
        newChild.screenTimeTimer = newScreenTimeTimer

        do {
            try viewContext.save()
            dismiss()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ChildEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ContentScreen(child: Child().example).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
