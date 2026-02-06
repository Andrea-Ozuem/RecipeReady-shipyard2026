//
//  EditableIngredientRow.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI
import Combine

struct EditableIngredientRow: View {
    @Binding var ingredient: Ingredient
    var onDelete: () -> Void
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Amount
            TextField("Amount", text: Binding(
                get: { ingredient.amount ?? "" },
                set: { ingredient.amount = $0.isEmpty ? nil : $0 }
            ))
            .font(.bodyRegular)
            .foregroundColor(.textPrimary)
            .frame(width: 80, alignment: .leading)
            .textFieldStyle(.plain) // Cleaner look
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1)) // Subtle edit hint
            .cornerRadius(4)
            .focused($isAmountFocused)
            
            // Ingredient Name
            TextField("Ingredient", text: $ingredient.name)
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textFieldStyle(.plain)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
                .focused($isNameFocused)
            
            // Delete Action
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}
