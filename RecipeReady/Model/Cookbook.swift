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
    @Attribute(.unique) var id: UUID
    var name: String
    var coverColor: String       // Hex color code
    var recipes: [Recipe]
    var isFavorites: Bool         // Special flag for the default "Favorites" cookbook
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        coverColor: String = "#FF6B35",  // Default orange
        recipes: [Recipe] = [],
        isFavorites: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.coverColor = coverColor
        self.recipes = recipes
        self.isFavorites = isFavorites
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
