//
//  Cookbook.swift
//  RecipeReady
//
//  SwiftData model for recipe cookbooks/collections.
//

import Foundation
import SwiftData

/// A cookbook/collection that can contain multiple recipes.
@Model
final class Cookbook {
    var id: UUID
    var title: String
    var isFavorites: Bool
    var createdAt: Date
    
    // Many-to-many relationship with recipes
    @Relationship(deleteRule: .nullify, inverse: \Recipe.cookbooks)
    var recipes: [Recipe]
    
    init(
        id: UUID = UUID(),
        title: String,
        isFavorites: Bool = false,
        createdAt: Date = Date(),
        recipes: [Recipe] = []
    ) {
        self.id = id
        self.title = title
        self.isFavorites = isFavorites
        self.createdAt = createdAt
        self.recipes = recipes
    }
}
