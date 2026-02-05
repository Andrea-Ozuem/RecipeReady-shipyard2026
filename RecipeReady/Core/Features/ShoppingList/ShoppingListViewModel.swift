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
    @Published var ingredients: [String] = []
    
    var isEmpty: Bool {
        ingredients.isEmpty
    }
    
    // Suggestion: Add function to toggle state for testing/demo purposes
    func toggleMockData() {
        if isEmpty {
            ingredients = [
                "2 large Eggs",
                "1 cup Milk",
                "500g Flour",
                "1 tsp Salt",
                "2 tbsp Olive Oil"
            ]
        } else {
            ingredients.removeAll()
        }
    }
}
