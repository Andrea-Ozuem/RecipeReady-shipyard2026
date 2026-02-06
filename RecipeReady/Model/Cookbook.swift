//
//  Cookbook.swift
//  RecipeReady
//
//  SwiftData model for a cookbook.
//

import Foundation
import SwiftData

@Model
final class Cookbook {
    var name: String
    var coverColor: String       // Hex color code
    var recipes: [Recipe]
    var isFavorites: Bool         // Special flag for the default "Favorites" cookbook
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        coverColor: String = "#FF6B35",  // Default orange
        recipes: [Recipe] = [],
        isFavorites: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.name = name
        self.coverColor = coverColor
        self.recipes = recipes
        self.isFavorites = isFavorites
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
