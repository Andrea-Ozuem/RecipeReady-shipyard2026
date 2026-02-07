//
//  SampleData.swift
//  RecipeReady
//
//  Shared sample data for seeding and UI placeholders.
//

import Foundation

struct SampleData {
    // 1. Featured Recipe (Hero)
    static var featured: Recipe {
        Recipe(
            title: "Casseroles are the Best Kick-off for Autumn",
            author: "Eitan Bernath",
            isFeatured: true,
            ingredients: [Ingredient(name: "Pasta", amount: "500g"), Ingredient(name: "Cheese", amount: "200g")],
            steps: [CookingStep(order: 1, instruction: "Bake it.")],
            imageURL: "https://images.unsplash.com/photo-1547516508-4c1f9c7c4ec3?auto=format&fit=crop&w=800&q=80", // Placeholder
            difficulty: "Medium",
            prepTime: 20,
            cookingTime: 45,
            servings: 4
        )
    }
    
    // 2. Eitan's Kitchen
    static var eitanRecipes: [Recipe] {
        [
            Recipe(
                title: "Oven Fresh and Cozy",
                author: "Eitan Bernath",
                imageURL: "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=600&q=80",
                difficulty: "Easy",
                prepTime: 10,
                cookingTime: 20
            ),
            Recipe(
                title: "Fluffy Pancakes",
                author: "Eitan Bernath",
                imageURL: "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=600&q=80",
                prepTime: 15,
                cookingTime: 15
            )
        ]
    }
    
    // 3. Cook This Tonight (Fast)
    static var tonightRecipes: [Recipe] {
        [
            Recipe(
                title: "Lemon Garlic Pasta",
                author: "Chef John",
                imageURL: "https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?auto=format&fit=crop&w=600&q=80",
                difficulty: "Easy",
                cookingTime: 15
            ),
            Recipe(
                title: "Avocado Toast",
                author: "Healthy Eats",
                imageURL: "https://images.unsplash.com/photo-1588137372308-15f75323a399?auto=format&fit=crop&w=600&q=80",
                difficulty: "Easy",
                cookingTime: 5
            )
        ]
    }
    
    // 4. Saved Videos
    static var videoRecipes: [Recipe] {
        [
            Recipe(
                title: "How to make Sushi",
                author: "Sushi Master",
                sourceLink: "https://youtube.com/watch?v=12345",
                imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=600&q=80",
                cookingTime: 60
            ),
            Recipe(
                title: "Best Burger Tutorial",
                author: "Burger King",
                 sourceLink: "https://tiktok.com/@burgerking/video/123456",
                imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80",
                cookingTime: 30
            )
        ]
    }
}
