//
//  ShoppingListExpandedView.swift
//  RecipeReady
//
//  Created for Grocery List Expanded State.
//

import SwiftUI
import SwiftData

struct ShoppingListExpandedView: View {
    @Bindable var recipe: ShoppingListRecipe
    
    var body: some View {
        VStack(spacing: 0) {
            // Servings Control
            HStack {
                Text("\(recipe.servings) Servings")
                    .font(.bodyBold)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                ServingsStepper(servings: $recipe.servings)
            }
            .padding(.vertical, 16)
            
            Divider()
            
            // Ingredients List
            VStack(spacing: 0) {
                ForEach(recipe.items) { item in
                    let scaledAmount = IngredientScaler.scale(
                        amount: item.quantity,
                        from: recipe.originalServings ?? 1,
                        to: recipe.servings
                    )
                    
                    ShoppingListIngredientRow(
                        ingredient: item,
                        quantityOverride: scaledAmount
                    ) {
                        item.isChecked.toggle()
                    }
                    
                    if item.id != recipe.items.last?.id {
                        Divider()
                            .opacity(0.5)
                    }
                }
            }
        }
        .padding(.horizontal, 20) // Match list padding
    }
}
