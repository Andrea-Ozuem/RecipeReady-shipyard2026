//
//  EditableTimeCircleView.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI
import Combine

struct EditableTimeCircleView: View {
    let title: String
    @Binding var minutes: Int?
    
    @State private var isEditing = false
    @State private var tempMinutes: Int = 0
    
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
            return "\(hours) h"
        } else {
            return "\(minutes) min"
        }
    }
    
    private var isSet: Bool {
        return minutes != nil && minutes! > 0
    }
    
    var body: some View {
        Button {
            tempMinutes = minutes ?? 0
            isEditing = true
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(isSet ? Color.orange : Color.divider, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                    if isSet {
                        Circle()
                            // Progress: 1.0 if >= 60 mins, else fraction of hour
                            .trim(from: 0.0, to: min(Double(minutes ?? 0) / 60.0, 1.0))
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    Text(timeString)
                        .font(isSet ? .bodyRegular : .bodyBold)
                        .foregroundColor(.textPrimary)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.textPrimary)
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                Form {
                    Section {
                        Picker("Duration", selection: $tempMinutes) {
                            Text("None").tag(0)
                            ForEach(Array(stride(from: 5, through: 180, by: 5)), id: \.self) { min in
                                if min >= 60 {
                                    Text("\(min / 60)h \(min % 60)m").tag(min)
                                } else {
                                    Text("\(min) min").tag(min)
                                }
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                .navigationTitle("Edit \(title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isEditing = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if tempMinutes == 0 {
                                minutes = nil
                            } else {
                                minutes = tempMinutes
                            }
                            isEditing = false
                        }
                    }
                }
                .presentationDetents([.height(300)])
            }
        }
    }
}

#Preview {
    HStack {
        EditableTimeCircleView(title: "Preparation", minutes: .constant(15))
        EditableTimeCircleView(title: "Baking", minutes: .constant(nil))
    }
}
