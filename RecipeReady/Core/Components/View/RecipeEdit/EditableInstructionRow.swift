//
//  EditableInstructionRow.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct EditableInstructionRow: View {
    @Binding var step: CookingStep
    var index: Int
    var onDelete: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step Number Circle
            Text("\(index)")
                .font(.captionMeta)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.primaryGreen))
                .padding(.top, 6) // Verify alignment with text
            
            // Instruction Text
            TextField("Step instruction", text: $step.instruction, axis: .vertical)
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .textFieldStyle(.plain)
                .padding(.vertical, 4)
                .padding(.horizontal, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
                .focused($isFocused)
            
            // Delete Action
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.6))
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 4)
    }
}
