//
//  ShoppingListExpandedView.swift
//  RecipeReady
//
//  Created for Shopping List Expanded State.
//

import SwiftUI

struct ShoppingListExpandedView: View {
    @Binding var recipe: ShoppingListRecipe
    @ObservedObject var viewModel: ShoppingListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Servings Control
            HStack {
                Text("\(recipe.servings) Servings")
                    .font(.bodyBold)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                ServingsStepper(servings: Binding(
                    get: { recipe.servings },
                    set: { newValue in
                        // Call ViewModel to update and re-calculate quantities if implemented
                        viewModel.updateServings(for: recipe.id, newCount: newValue)
                    }
                ))
            }
            .padding(.vertical, 16)
            
            Divider()
            
            // Ingredients List
            VStack(spacing: 0) {
                ForEach(recipe.ingredients) { ingredient in
                    ShoppingListIngredientRow(ingredient: ingredient) {
                        viewModel.toggleIngredient(recipeID: recipe.id, ingredientID: ingredient.id)
                    }
                    
                    if ingredient.id != recipe.ingredients.last?.id {
                        Divider()
                            .opacity(0.5)
                    }
                }
            }
        }
        .padding(.horizontal, 20) // Match list padding
    }
}
