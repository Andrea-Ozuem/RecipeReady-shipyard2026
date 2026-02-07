//
//  Recipe.swift
//  RecipeReady
//
//  SwiftData model for a recipe.
//

import Foundation
import SwiftData

@Model
final class Recipe {
    @Attribute(.unique) var id: UUID
    var title: String
    var author: String? // Added for Home screen
    var isFeatured: Bool // Added for Home screen hero
    var ingredients: [Ingredient]
    var steps: [CookingStep]
    var sourceLink: String?
    var sourceCaption: String? // Added to support displaying extracted caption
    var imageURL: String?
    
    // Metadata
    var difficulty: String?
    var prepTime: Int?           // in minutes
    var cookingTime: Int?         // in minutes 
    var restingTime: Int?         // in minutes
    var servings: Int?
    
    var confidenceScore: Double
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String? = nil, // Added parameter
        isFeatured: Bool = false, // Added parameter
        ingredients: [Ingredient] = [],
        steps: [CookingStep] = [],
        sourceLink: String? = nil,
        sourceCaption: String? = nil, // New parameter
        imageURL: String? = nil,
        difficulty: String? = nil,
        prepTime: Int? = nil,
        cookingTime: Int? = nil,    // Updated parameter name
        bakingTime: Int? = nil,     // Keep for backwards compatibility, maps to cookingTime
        restingTime: Int? = nil,
        servings: Int? = nil,
        confidenceScore: Double = 0.5,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.isFeatured = isFeatured
        self.ingredients = ingredients
        self.steps = steps
        self.sourceLink = sourceLink
        self.sourceCaption = sourceCaption
        self.imageURL = imageURL
        self.difficulty = difficulty
        self.prepTime = prepTime
        // Handle both cookingTime and bakingTime (backwards compatibility)
        self.cookingTime = cookingTime ?? bakingTime
        self.restingTime = restingTime
        self.servings = servings
        self.confidenceScore = confidenceScore
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // For backwards compatibility with existing code using bakingTime
    var bakingTime: Int? {
        get { cookingTime }
        set { cookingTime = newValue }
    }
}
