//
//  TimerView.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var child: Child
    
    @StateObject var notifications = Notifications()
    @AppStorage("selectedTimer") var selectedTimerType: ActivityType = .activity
    
    @State var timer = UsedTimer(id: UUID(), status: .idle, backgroundTime: nil, amount: 1800.0, total: 1800.0, progress: 1.0)
    
    var body: some View {
        VStack {
            Text("Screen Time Available: \(child.availableScreenTime.time)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            Picker("", selection: $selectedTimerType) {
                ForEach(ActivityType.allCases) { activityType in
                    Label(activityType.rawValue, systemImage: activityType.icon).tag(activityType).labelStyle(.iconOnly)
                    //                    Text(activityType.rawValue).tag(activityType)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Text(selectedTimerType.rawValue)
                .font(.largeTitle)
            
            TimerProgressView(currentTimer: $timer, endTimer: endTimer)
            
            HStack {
                if timer.status == .paused {
                    Button {
                        resetTimer()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.mint)
                            .clipShape(Circle())
                    }
                }
                
                if selectedTimerType != .screenTime {
                    Button {
                        if timer.status == .idle || timer.status == .paused {
                            startTimer()
                        } else if timer.status == .active {
                            pauseTimer(completion: notifications.cancelNotification)
                        }
                    } label: {
                        if timer.status == .idle || timer.status == .paused {
                            Image(systemName: "play.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.mint)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "pause.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.mint)
                                .clipShape(Circle())
                        }
                    }
                } else if selectedTimerType == .screenTime && child.availableScreenTime > 0.0 {
                    Button {
                        if timer.status == .idle || timer.status == .paused {
                            startTimer()
                        } else if timer.status == .active {
                            stopTimer()
                        }
                    } label: {
                        if timer.status == .idle || timer.status == .paused {
                            Image(systemName: "play.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.mint)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "stop.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.mint)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadTimer)
        .onChange(of: selectedTimerType) { [selectedTimerType] newValue in
            if timer.status == .active {
                pauseTimer(selectedTimerType, completion: notifications.cancelNotification)
            }
            
            loadTimer()
        }
        .onReceive(
            NotificationCenter
                .default
                .publisher(
                    for: UIApplication.willResignActiveNotification
                )) { _ in movingToBackground() }
            .onReceive(
                NotificationCenter
                    .default
                    .publisher(
                        for: UIApplication.didBecomeActiveNotification
                    )) { _ in movingToForeground() }
    }
    
    func loadTimer() {
        if timer.status != .active {
            switch selectedTimerType {
            case .activity:
                timer = UsedTimer(
                    id: child.activityTimer?.id,
                    status: child.activityTimer?.statusDisplay,
                    backgroundTime: child.activityTimer?.backgroundTime,
                    amount: child.activityTimer?.amount,
                    total: child.activityTimer?.total,
                    progress: child.activityTimer?.progress
                )
            case .exercise:
                timer = UsedTimer(
                    id: child.exerciseTimer?.id!,
                    status: child.exerciseTimer?.statusDisplay,
                    backgroundTime: child.exerciseTimer?.backgroundTime,
                    amount: child.exerciseTimer?.amount,
                    total: child.exerciseTimer?.total,
                    progress: child.exerciseTimer?.progress
                )
            case .screenTime:
                timer = UsedTimer(
                    id: child.screenTimeTimer?.id!,
                    status: child.screenTimeTimer?.statusDisplay,
                    backgroundTime: child.screenTimeTimer?.backgroundTime,
                    amount: child.availableScreenTime,
                    total: child.availableScreenTime,
                    progress: 1.0
                )
            }
        }
    }
    
    func resetTimer() {
        withAnimation {
            let amount = selectedTimerType == .exercise ? 600.0 : 1800.0
            
            timer = UsedTimer(
                id: UUID(),
                status: .idle,
                amount: amount,
                total: amount,
                progress: 1.0
            )
            
            switch selectedTimerType {
            case .activity:
                child.activityTimer = child.defaultActivityTimer
            case .exercise:
                child.exerciseTimer = child.defaultExerciseTimer
            case .screenTime:
                child.screenTimeTimer = child.defaultScreenTimeTimer
            }
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            notifications.cancelNotification()
        }
    }
    
    func stopTimer() {
        withAnimation {
            timer.status = .idle
            
            child.objectWillChange.send()
            
            guard let screenTimeTimer = child.screenTimeTimer else { return }
            guard screenTimeTimer.total > 0.0 else { return }
            guard screenTimeTimer.amount > 0.0 else { return }
            
            screenTimeTimer.status = timer.status?.rawValue
            screenTimeTimer.backgroundTime = timer.backgroundTime!
            screenTimeTimer.amount = timer.amount!
            screenTimeTimer.progress = timer.progress!
            
            let newSpendRecord = TimeEvent(context: viewContext)
            newSpendRecord.id = UUID()
            newSpendRecord.child = child
            newSpendRecord.title = "Time Spent"
            newSpendRecord.timestamp = Date()
            newSpendRecord.timeSpent = timer.total! - timer.amount!
            
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
    
    func pauseTimer(_ selectedTimer: ActivityType? = nil, completion: @escaping () -> Void = {}) {
        let timerType = selectedTimer != nil ? selectedTimer : selectedTimerType
        
        withAnimation {
            switch timerType {
            case .activity:
                timer.status = .paused
                
                child.activityTimer?.objectWillChange.send()
                
                
                child.activityTimer?.status = timer.status?.rawValue
                child.activityTimer?.backgroundTime = timer.backgroundTime
                child.activityTimer?.amount = timer.amount!
                child.activityTimer?.progress = timer.progress!
            case .exercise:
                timer.status = .paused
                
                child.exerciseTimer?.objectWillChange.send()
                
                child.exerciseTimer?.status = timer.status?.rawValue
                child.exerciseTimer?.backgroundTime = timer.backgroundTime
                child.exerciseTimer?.amount = timer.amount!
                child.exerciseTimer?.progress = timer.progress!
            case .screenTime:
                timer.status = .paused
                
                child.screenTimeTimer?.objectWillChange.send()
                
                child.screenTimeTimer?.status = timer.status?.rawValue
                child.screenTimeTimer?.backgroundTime = timer.backgroundTime
                child.screenTimeTimer?.amount = timer.amount!
                child.screenTimeTimer?.progress = timer.progress!
            case .none:
                timer.status = .paused
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func startTimer() {
        withAnimation {
            timer.status = .active
        }
        
        notifications.addNotification(timeRemaining: timer.amount!, selectedTimerType: selectedTimerType)
    }
    
    func endTimer() {
        withAnimation {
            switch selectedTimerType {
            case .activity:
                timer.amount = 0.0
                timer.progress = 0.0
                timer.status = .idle
                
                timer.backgroundTime = nil
                timer.amount = 1800.0
                timer.total = 1800.0
                timer.progress = 1.0
                
                child.activityTimer?.status = "idle"
                child.activityTimer?.amount = 1800.0
                child.activityTimer?.total = 1800.0
                child.activityTimer?.progress = 1.0
                
                let newEvent = TimeEvent(context: viewContext)
                newEvent.id = UUID()
                newEvent.title = selectedTimerType.rawValue
                newEvent.timestamp = Date()
                newEvent.timeEarned = 1800
                newEvent.child = child
            case .exercise:
                timer.amount = 0.0
                timer.progress = 0.0
                timer.status = .idle
                
                timer.backgroundTime = nil
                timer.amount = 600.0
                timer.total = 600.0
                timer.progress = 1.0
                
                child.exerciseTimer?.status = "idle"
                child.exerciseTimer?.amount = 600.0
                child.exerciseTimer?.total = 600.0
                child.exerciseTimer?.progress = 1.0
                
                let newEvent = TimeEvent(context: viewContext)
                newEvent.id = UUID()
                newEvent.title = selectedTimerType.rawValue
                newEvent.timestamp = Date()
                newEvent.timeEarned = 1800
                newEvent.child = child
            case .screenTime:
                timer.amount = 0.0
                timer.progress = 0.0
                timer.status = .idle
                
                timer.backgroundTime = nil
                timer.amount = 0.0
                timer.total = 0.0
                timer.progress = 0.0
                
                child.screenTimeTimer?.status = "idle"
                child.screenTimeTimer?.amount = 1800.0
                child.screenTimeTimer?.total = 1800.0
                child.screenTimeTimer?.progress = 1.0
                
                let newEvent = TimeEvent(context: viewContext)
                newEvent.id = UUID()
                newEvent.timestamp = Date()
                newEvent.title = "Screen Time Spent"
                newEvent.timeSpent = timer.total!
                newEvent.child = child
            }
            
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
    
    func movingToBackground() {
        print("Moving to the background")
        if timer.status == .active {
            timer.backgroundTime = Date()
            pauseTimer()
        }
    }
    
    func movingToForeground() {
        print("Moving to the foreground")
        guard let backgroundTime = timer.backgroundTime else { return }
        
        let deltaTime: Double = Double(Date().timeIntervalSince(backgroundTime))
        
        if deltaTime < timer.amount! {
            timer.amount! -= deltaTime
            timer.progress = timer.amount! / timer.total!
            timer.backgroundTime = nil
            
            startTimer()
        } else {
            endTimer()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentScreen(child: Child().example).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
