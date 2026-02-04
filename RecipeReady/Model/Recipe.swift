//
//  Recipe.swift
//  RecipeReady
//
//  SwiftData model for a complete recipe.
//

import Foundation
import SwiftData

/// A complete recipe extracted from a video.
@Model
final class Recipe {
    var id: UUID
    var title: String
    var ingredientsData: Data?
    var stepsData: Data?
    var sourceLink: String?
    var sourceCaption: String?
    var imageURL: String?
    var difficulty: String? // e.g. "Medium"
    
    // Time metadata (in minutes)
    var prepTime: Int?
    var bakingTime: Int?
    var restingTime: Int?
    
    var confidenceScore: Double
    var createdAt: Date
    var updatedAt: Date
    
    /// Computed property to encode/decode ingredients from Data
    var ingredients: [Ingredient] {
        get {
            guard let data = ingredientsData else { return [] }
            return (try? JSONDecoder().decode([Ingredient].self, from: data)) ?? []
        }
        set {
            ingredientsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// Computed property to encode/decode cooking steps from Data
    var steps: [CookingStep] {
        get {
            guard let data = stepsData else { return [] }
            return (try? JSONDecoder().decode([CookingStep].self, from: data)) ?? []
        }
        set {
            stepsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        ingredients: [Ingredient] = [],
        steps: [CookingStep] = [],
        sourceLink: String? = nil,
        sourceCaption: String? = nil,
        imageURL: String? = nil,
        difficulty: String? = nil,
        prepTime: Int? = nil,
        bakingTime: Int? = nil,
        restingTime: Int? = nil,
        confidenceScore: Double = 0.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.sourceLink = sourceLink
        self.sourceCaption = sourceCaption
        self.imageURL = imageURL
        self.difficulty = difficulty
        self.prepTime = prepTime
        self.bakingTime = bakingTime
        self.restingTime = restingTime
        self.confidenceScore = confidenceScore
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        // Encode arrays to Data
        self.ingredientsData = try? JSONEncoder().encode(ingredients)
        self.stepsData = try? JSONEncoder().encode(steps)
    }
}
