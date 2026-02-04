//
//  TimeCircleView.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct TimeCircleView: View {
    let title: String
    let minutes: Int
    
    // Formatting logic: if > 60 min, show hours? 
    // Screenshot shows "24h" for Resting.
    private var timeString: String {
        if minutes >= 60 {
            let hours = minutes / 60
            return "\(hours) h"
        } else {
            return "\(minutes) min"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.softBeige, lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                // Orange progress arc (decorator)
                // In screenshot, it's just a partial arc. We can hardcode ~30% for aesthetic.
                Circle()
                    .trim(from: 0.0, to: 0.35)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text(timeString)
                    .font(.captionMeta)
                    .foregroundColor(.textPrimary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    HStack {
        TimeCircleView(title: "Preparation", minutes: 15)
        TimeCircleView(title: "Baking", minutes: 40)
        TimeCircleView(title: "Resting", minutes: 1440)
    }
}
