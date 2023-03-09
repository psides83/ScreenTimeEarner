//
//  ProgressViewStyles.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/6/23.
//

import Foundation
import SwiftUI

struct GaugeProgressStyle: ProgressViewStyle {
    var trimAmount = 1
    var strokeColor = Color.mint
    var strokeWidth = 25.0
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        return ZStack {
            Circle()
                .stroke(strokeColor.opacity(0.4), style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
            
            Circle()
                .rotation(Angle(degrees: 270))
                .trim(from: 0, to: CGFloat(trimAmount) * CGFloat(fractionCompleted))
                .stroke(strokeColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .butt))
                .animation(.linear, value: trimAmount)
        }
    }
}

struct GueageView: View {
    @State private var progress = 0.2

    var body: some View {
        ProgressView("Label", value: progress, total: 1.0)
            .frame(width: 200)
            .onTapGesture {
                if progress < 1.0 {
                    withAnimation {
                        progress += 0.2
                    }
                }
            }
            .progressViewStyle(GaugeProgressStyle())
    }
}

struct GuageView_Previews: PreviewProvider {
    static var previews: some View {
        GueageView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

