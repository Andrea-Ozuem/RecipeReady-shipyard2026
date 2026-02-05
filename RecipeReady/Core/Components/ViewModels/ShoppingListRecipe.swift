//
//  ShoppingListRecipe.swift
//  RecipeReady
//
//  Created for Shopping List implementation.
//

import Foundation

struct ShoppingListIngredient: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let quantity: String
    var isChecked: Bool = false
    
    init(id: UUID = UUID(), name: String, quantity: String, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
    }
}

struct ShoppingListRecipe: Identifiable {
    let id = UUID()
    let title: String
    let imageURL: String?
    let totalItems: Int
    let missingItems: Int
    
    // Expanded State Props
    var isExpanded: Bool = false
    var servings: Int = 2
    var ingredients: [ShoppingListIngredient] = []
}
