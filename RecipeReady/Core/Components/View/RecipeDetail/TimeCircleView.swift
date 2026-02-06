//
//  TimeCircleView.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct TimeCircleView: View {
    let title: String
    let minutes: Int?
    
    // Formatting logic
    private var timeString: String {
        guard let minutes = minutes, minutes > 0 else {
            return "--"
        }
        
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins > 0 {
                return "\(hours)h \(mins)m"
            }
            return "\(hours)h"
        } else {
            return "\(minutes) min"
        }
    }
    
    private var progress: Double {
        guard let minutes = minutes, minutes > 0 else { return 0.0 }
        return min(Double(minutes) / 60.0, 1.0)
    }
    
    private var strokeColor: Color {
        guard let minutes = minutes, minutes > 0 else { return Color.divider }
        return Color.orange
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Background Circle structure
                Circle()
                    .stroke(Color.divider, lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                // Orange progress arc
                if progress > 0 {
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                }
                
                Text(timeString)
                    .font((minutes ?? 0) > 0 ? .bodyRegular : .bodyBold)
                    .foregroundColor(.textPrimary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview {
    HStack {
        TimeCircleView(title: "Preparation", minutes: 15)
        TimeCircleView(title: "Baking", minutes: nil) // Should show --
        TimeCircleView(title: "Resting", minutes: 90) // Should show 1h 30m
    }
}
