//
//  Recipe+Mock.swift
//  RecipeReady
//
//  Created for UI Previews.
//

import Foundation

extension Recipe {
    static let mock: Recipe = {
        let recipe = Recipe(
            title: "Roasted Chicken with Olives",
            ingredients: [
                Ingredient(name: "whole chickens", amount: "1½ kg"),
                Ingredient(name: "prunes", amount: "65 g"),
                Ingredient(name: "jarred pitted green olives", amount: "65 g"),
                Ingredient(name: "garlic", amount: "3 cloves"),
                Ingredient(name: "capers", amount: "2 tbsp"),
                Ingredient(name: "dried oregano", amount: "1½ tbsp"),
                Ingredient(name: "bay leaves", amount: "3"),
                Ingredient(name: "chili powder", amount: "1 tsp"),
                Ingredient(name: "red wine vinegar", amount: "120 ml"),
                Ingredient(name: "white wine", amount: "120 ml"),
                Ingredient(name: "honey", amount: "2 tbsp"),
                Ingredient(name: "salt", amount: "1 tbsp"),
                Ingredient(name: "pepper", amount: "2 tsp"),
                Ingredient(name: "lemon", amount: "1")
            ],
            steps: [
                CookingStep(order: 1, instruction: "Preheat oven to 200°C (400°F)."),
                CookingStep(order: 2, instruction: "Combine prunes, olives, garlic, capers, oregano, bay leaves, chili powder, vinegar, wine, honey, salt, and pepper in a large bowl."),
                CookingStep(order: 3, instruction: "Add chicken and coat well with the marinade.")
            ],
            sourceLink: "https://kitchenstories.com",
            imageURL: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80", // Salad Unsplash
            difficulty: "Medium",
            prepTime: 15,
            bakingTime: 40,
            restingTime: 24 * 60, // 24h
            confidenceScore: 1.0
        )
        return recipe
    }()
}
