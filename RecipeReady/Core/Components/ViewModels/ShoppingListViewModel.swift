//
//  ShoppingListViewModel.swift
//  RecipeReady
//
//  Created for Shopping List implementation.
//

import SwiftUI
import Combine

@MainActor
class ShoppingListViewModel: ObservableObject {
    enum Tab {
        case recipes
        case allItems
    }

    @Published var recipes: [ShoppingListRecipe] = []
    @Published var selectedTab: Tab = .recipes
    
    var isEmpty: Bool {
        recipes.isEmpty
    }
    
    // Suggestion: Add function to toggle state for testing/demo purposes
    // Suggestion: Add function to toggle state for testing/demo purposes
    // Helper to ensure unique IDs
    private func makeIngredient(name: String, quantity: String) -> ShoppingListIngredient {
        let ing = ShoppingListIngredient(id: UUID(), name: name, quantity: quantity)
        print("Created Ingredient: \(name) - ID: \(ing.id)")
        return ing
    }

    func toggleMockData() {
        if isEmpty {
            recipes = [
                ShoppingListRecipe(
                    title: "Lamb's lettuce salad with crispy potatoes",
                    imageURL: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500&q=80",
                    totalItems: 14,
                    missingItems: 14,
                    ingredients: [
                        makeIngredient(name: "lamb's lettuce", quantity: "200 g"),
                        makeIngredient(name: "waxy potatoes", quantity: "300 g"),
                        makeIngredient(name: "brown mushrooms", quantity: "200 g"),
                        makeIngredient(name: "shallot", quantity: "1"),
                        makeIngredient(name: "chives", quantity: "10 g")
                    ]
                ),
                ShoppingListRecipe(
                    title: "Chicken Marbella",
                    imageURL: "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=500&q=80",
                    totalItems: 14,
                    missingItems: 14,
                    ingredients: [
                        makeIngredient(name: "Chicken thighs", quantity: "1 kg"),
                        makeIngredient(name: "Prunes", quantity: "1 cup"),
                        makeIngredient(name: "Olives", quantity: "1/2 cup")
                    ]
                ),
                ShoppingListRecipe(
                    title: "Cinnamon Roll Focaccia",
                    imageURL: "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&q=80",
                    totalItems: 12,
                    missingItems: 12,
                    ingredients: [
                        makeIngredient(name: "Flour", quantity: "500 g"),
                        makeIngredient(name: "Yeast", quantity: "7 g"),
                        makeIngredient(name: "Sugar", quantity: "50 g")
                    ]
                )
            ]
        } else {
            recipes.removeAll()
        }
    }
    
    func toggleExpansion(for recipeID: UUID) {
        if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
            recipes[index].isExpanded.toggle()
        }
    }
    
    func updateServings(for recipeID: UUID, newCount: Int) {
        if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
            // Here you would typically recalculate ingredient quantities based on servings
            recipes[index].servings = newCount
        }
    }
    
    func toggleIngredient(recipeID: UUID, ingredientID: UUID) {
        print("Attempting to toggle ingredient: \(ingredientID) in recipe: \(recipeID)")
        if let recipeIndex = recipes.firstIndex(where: { $0.id == recipeID }) {
            if let ingredientIndex = recipes[recipeIndex].ingredients.firstIndex(where: { $0.id == ingredientID }) {
                print("Toggling Index: \(ingredientIndex) - Name: \(recipes[recipeIndex].ingredients[ingredientIndex].name)")
                recipes[recipeIndex].ingredients[ingredientIndex].isChecked.toggle()
            } else {
                print("Ingredient NOT FOUND with ID: \(ingredientID)")
            }
        } else {
             print("Recipe NOT FOUND with ID: \(recipeID)")
        }
    }
    var allIngredients: [ShoppingListIngredient] {
        recipes.flatMap { $0.ingredients }
    }
    
    func toggleAllIngredientsItem(id: UUID) {
        for (recipeIndex, recipe) in recipes.enumerated() {
            if let ingredientIndex = recipe.ingredients.firstIndex(where: { $0.id == id }) {
                recipes[recipeIndex].ingredients[ingredientIndex].isChecked.toggle()
                return
            }
        }
    }
    
    func removeRecipe(id: UUID) {
        withAnimation {
            recipes.removeAll { $0.id == id }
        }
    }
    
    func unmarkAll() {
        for i in 0..<recipes.count {
            for j in 0..<recipes[i].ingredients.count {
                recipes[i].ingredients[j].isChecked = false
            }
        }
    }
}
