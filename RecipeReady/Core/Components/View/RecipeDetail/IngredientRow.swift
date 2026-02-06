//
//  IngredientRow.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct IngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Amount (Left aligned) - show "-" if missing
            Text(ingredient.amount ?? "-")
                .font(.bodyRegular)
                .foregroundColor(ingredient.amount == nil ? .textSecondary : .textPrimary)
                .frame(width: 60, alignment: .leading)
            
            // Ingredient Name
            Text(ingredient.name)
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 8) {
        IngredientRow(ingredient: Ingredient(name: "whole chickens", amount: "1½ kg"))
        IngredientRow(ingredient: Ingredient(name: "prunes", amount: "65 g"))
        IngredientRow(ingredient: Ingredient(name: "jarred pitted green olives", amount: "65 g"))
    }
    .padding()
}
