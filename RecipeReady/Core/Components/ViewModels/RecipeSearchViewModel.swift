//
//  RecipeSearchViewModel.swift
//  RecipeReady
//
//  ViewModel for the Recipe Search view, managing search text, ingredient selection,
//  and performing local search against SwiftData recipes.
//

import SwiftUI
import Combine
import SwiftData

@MainActor
class RecipeSearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var selectedIngredients: Set<String> = []
    @Published var favoriteIngredients: Set<String> = []
    
    // The results to display based on selection
    @Published var searchResults: [Recipe] = []
    
    // Suggested ingredients (filtered by search text)
    @Published var availableIngredients: [String] = []
    
    // MARK: - Private Properties
    private var allRecipes: [Recipe] = []
    private var allKnownIngredients: Set<String> = []
    
    private let favoritesKey = "RecipeReady_FavoriteIngredients"
    
    init() {
        loadFavorites()
    }
    
    private let commonIngredients = [
        "Egg", "Milk", "Rice", "Chicken Breast", "Tomato", "Potato", "Onion", "Garlic", "Pasta",
        "Cheese", "Butter", "Flour", "Sugar", "Salt", "Pepper", "Olive Oil"
    ]
    
    // MARK: - Data Loading
    
    /// Loads recipes from SwiftData and extracts unique ingredients
    func loadData(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            self.allRecipes = try context.fetch(descriptor)
            
            // Extract all unique ingredients from all recipes
            // We normalize them to lowercase to avoid duplicates like "Tomato" vs "tomato"
            var ingredients = Set<String>(commonIngredients) // Start with common ingredients
            
            for recipe in allRecipes {
                for ingredient in recipe.ingredients {
                    let cleanedName = ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
                    if !cleanedName.isEmpty {
                        ingredients.insert(cleanedName)
                    }
                }
            }
            
            self.allKnownIngredients = ingredients
            // Initial filter update?
             objectWillChange.send() // Force UI update just in case
        } catch {
            print("Failed to fetch recipes: \(error)")
            // Fallback to common ingredients even on error
            self.allKnownIngredients = Set(commonIngredients)
        }
    }
    
    // MARK: - Computed Properties / Filtering
    
    /// Returns ingredients that match the search text (and aren't already selected)
    var filteredIngredients: [String] {
        let available = Array(allKnownIngredients).filter { !selectedIngredients.contains($0) }.sorted()
        
        if searchText.isEmpty {
            return available
        } else {
            return available.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
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
            searchText = "" // Clear search logic
        }
        performSearch()
    }
    
    /// Filters recipes that contain *at least one* of the selected ingredients (OR logic)
    /// OR *all* (AND logic). Usually "Search by ingredients" implies "What can I allow make with this?"
    /// Let's go with: Show recipes that contain ANY of the selected ingredients, sorted by number of matches?
    /// OR: Show recipes that match ALL selected ingredients?
    /// A common pattern is: "I have Chicken and Rice". Show me recipes with BOTH.
    /// Let's implement AND logic first (restrictive), as it's more specific.
    private func performSearch() {
        guard !selectedIngredients.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = allRecipes.filter { recipe in
            // Check if recipe contains ALL selected ingredients
            // Using localizedCaseInsensitiveContains for better matching
            let recipeIngredientNames = recipe.ingredients.map { $0.name.lowercased() }
            
            // Convert selected to lowercased for comparison
            let required = selectedIngredients.map { $0.lowercased() }
            
            // Check if every required ingredient is present in the recipe's ingredients
            // Loose matching: checking if recipe ingredient string contains the tag or vice versa
            return required.allSatisfy { req in
                recipeIngredientNames.contains { name in
                    name.contains(req) || req.contains(name)
                }
            }
        }
    }
    
    // MARK: - Favorites Logic
    
    func toggleFavorite(_ ingredient: String) {
        if favoriteIngredients.contains(ingredient) {
            favoriteIngredients.remove(ingredient)
        } else {
            favoriteIngredients.insert(ingredient)
        }
        saveFavorites()
    }
    
    func isFavorite(_ ingredient: String) -> Bool {
        favoriteIngredients.contains(ingredient)
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteIngredients = Set(data)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIngredients), forKey: favoritesKey)
    }
}
