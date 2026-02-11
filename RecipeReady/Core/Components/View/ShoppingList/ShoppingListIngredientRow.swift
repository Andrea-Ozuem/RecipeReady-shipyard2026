//
//  ShoppingListIngredientRow.swift
//  RecipeReady
//
//  Created for Grocery List Expanded State.
//

import SwiftUI
import SwiftData

struct ShoppingListIngredientRow: View {
    let ingredient: ShoppingListItem
    var quantityOverride: String? // Added for scaling support
    let onToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(.bodyBold)
                    .foregroundStyle(ingredient.isChecked ? Color.textSecondary : Color.textPrimary)
                    .strikethrough(ingredient.isChecked)
                
                Text(quantityOverride ?? ingredient.quantity)
                    .font(.bodyRegular)
                    .foregroundStyle(ingredient.isChecked ? Color.textSecondary : Color.textPrimary)
                    .strikethrough(ingredient.isChecked)
            }
            
            Spacer()
            
            Button(action: onToggle) {
                ZStack {
                    // Background & Border
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ingredient.isChecked ? Color.primaryGreen : Color.clear)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(ingredient.isChecked ? Color.primaryGreen : Color.textSecondary, lineWidth: 1.5)
                    
                    // Icon
                    if ingredient.isChecked {
                        Image(systemName: "checkmark")
                            .font(.iconSmall)
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

#Preview {
    VStack {
        // Mock data for preview
        ShoppingListIngredientRow(
            ingredient: ShoppingListItem(name: "lamb's lettuce", quantity: "200 g", isChecked: false),
            onToggle: {}
        )
        ShoppingListIngredientRow(
            ingredient: ShoppingListItem(name: "waxy potatoes", quantity: "300 g", isChecked: true),
            onToggle: {}
        )
    }
    .padding()
}
