//
//  ActivityCell.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import SwiftUI

struct ActivityCell: View {
    
    let earning: TimeEvent
    
    var body: some View {
        HStack {
            Text(earning.typeDisplay)
            
            Spacer()
            
            Text(earning.timestamp?.medium ?? "")
        }
    }
}
