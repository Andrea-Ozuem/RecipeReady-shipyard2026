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
    @Published var favoriteIngredients: Set<String> = [] // Mock favorites
    
    // Hardcoded suggestions for now as per design mockup
    let suggestedIngredients = [
        "milk", "rice", "tofu", "salmon fillet", 
        "tomato", "potato", "chicken breast", "shrimp",
        "cheese", "onion", "garlic", "pasta",
        "Alpine cheese", "blue cheese", "Brie cheese", "burrata cheese",
        "Camembert cheese", "cheddar cheese"
    ]
    
    // MARK: - Computed Properties
    var filteredIngredients: [String] {
        let available = suggestedIngredients.filter { !selectedIngredients.contains($0) }
        
        if searchText.isEmpty {
            return available
        } else {
            return available.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Sort selected ingredients to keep order stable (optional, or use array if order matters)
    var sortedSelectedIngredients: [String] {
        selectedIngredients.sorted()
    }
    
    var sortedFavoriteIngredients: [String] {
        favoriteIngredients.sorted()
    }
    
    // MARK: - Actions
    func toggleIngredient(_ ingredient: String) {
        if selectedIngredients.contains(ingredient) {
            selectedIngredients.remove(ingredient)
        } else {
            selectedIngredients.insert(ingredient)
            searchText = "" // Clear search to close dropdown and allow next entry
        }
    }
    
    func isSelected(_ ingredient: String) -> Bool {
        selectedIngredients.contains(ingredient)
    }
    
    // MARK: - Favorites Logic
    
    func toggleFavorite(_ ingredient: String) {
        if favoriteIngredients.contains(ingredient) {
            favoriteIngredients.remove(ingredient)
        } else {
            favoriteIngredients.insert(ingredient)
        }
    }
    
    func isFavorite(_ ingredient: String) -> Bool {
        favoriteIngredients.contains(ingredient)
    }
    
    func saveFavourites() {
        // Placeholder for saving favourite ingredients
        print("Saving favourites: \(selectedIngredients)")
    }
}
