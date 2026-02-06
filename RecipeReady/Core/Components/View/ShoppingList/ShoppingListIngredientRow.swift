//
//  ShoppingListIngredientRow.swift
//  RecipeReady
//
//  Created for Shopping List Expanded State.
//

import SwiftUI
import SwiftData

struct ShoppingListIngredientRow: View {
    let ingredient: ShoppingListItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(.bodyBold)
                    .foregroundStyle(ingredient.isChecked ? Color.textSecondary : Color.textPrimary)
                    .strikethrough(ingredient.isChecked)
                
                Text(ingredient.quantity)
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
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle()) // Make full row tappable if desired, currently button handles tap
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
