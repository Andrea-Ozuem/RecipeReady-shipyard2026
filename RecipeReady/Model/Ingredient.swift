//
//  Ingredient.swift
//  RecipeReady
//
//  Models an ingredient with name, amount, and optional link.
//

import Foundation

/// A single ingredient in a recipe.
struct Ingredient: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var amount: String?
    var link: String?
    
    init(name: String, amount: String? = nil, link: String? = nil) {
        self.name = name
        self.amount = amount
        self.link = link
    }
}
