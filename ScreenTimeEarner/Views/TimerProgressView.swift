//
//  TimerProgressView.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import SwiftUI

struct TimerProgressView: View {
    
//    let status: TimerStatus
//    let total: Double
//    @State var progress: Double
//    @Binding var timeRemaining: Double
    @Binding var currentTimer: UsedTimer
    let endTimer: () -> Void
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ProgressView("Label", value: currentTimer.progress, total: 1.0)
                .frame(width: 200)
                .progressViewStyle(GaugeProgressStyle())
            
            Text(currentTimer.amount!.time)
                .font(.title)
                .fontWeight(.semibold)
                .onReceive(timer) { _ in
                    if currentTimer.status == .active {
                        if currentTimer.amount! > 0 {
                            currentTimer.amount! -= 1
                        }
                        
                        if currentTimer.amount! > 0 {
                            withAnimation {
                                currentTimer.progress! -= 1.0 / currentTimer.total!
                            }
                        }
                        
                        if currentTimer.amount! == 0 {
                            endTimer()
                        }
                    }
                }
        }
    }
}
