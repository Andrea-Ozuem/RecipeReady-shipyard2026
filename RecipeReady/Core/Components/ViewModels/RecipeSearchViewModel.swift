//
//  RecipeSearchViewModel.swift
//  RecipeReady
//
//  ViewModel for the Recipe Search view, managing search text and ingredient selection.
//

import SwiftUI
import Combine

class RecipeSearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var selectedIngredients: Set<String> = []
    
    // Hardcoded suggestions for now as per design mockup
    let suggestedIngredients = [
        "milk", "rice", "tofu", "salmon fillet", 
        "tomato", "potato", "chicken breast", "shrimp",
        "cheese", "onion", "garlic", "pasta"
    ]
    
    // MARK: - Computed Properties
    var filteredIngredients: [String] {
        if searchText.isEmpty {
            return suggestedIngredients
        } else {
            return suggestedIngredients.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Actions
    func toggleIngredient(_ ingredient: String) {
        if selectedIngredients.contains(ingredient) {
            selectedIngredients.remove(ingredient)
        } else {
            selectedIngredients.insert(ingredient)
        }
    }
    
    func isSelected(_ ingredient: String) -> Bool {
        selectedIngredients.contains(ingredient)
    }
    
    func saveFavourites() {
        // Placeholder for saving favourite ingredients
        print("Saving favourites: \(selectedIngredients)")
    }
}
