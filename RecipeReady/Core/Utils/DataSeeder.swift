//
//  DataSeeder.swift
//  RecipeReady
//
//  Populates the app with sample data for demonstration.
//

import Foundation
import SwiftData

struct DataSeeder {
    static func seed(context: ModelContext) {
        // Check if recipes exist
        let descriptor = FetchDescriptor<Recipe>()
        do {
            let count = try context.fetchCount(descriptor)
            if count > 0 { return } // Already seeded
        } catch {
            print("Error checking recipes: \(error)")
            return
        }
        
        print("🌱 Seeding sample data...")
        
        // 1. Featured Recipe (Hero)
        let featured = Recipe(
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
        context.insert(featured)
        
        // 2. Eitan's Kitchen
        let eitan1 = Recipe(
            title: "Oven Fresh and Cozy",
            author: "Eitan Bernath",
            imageURL: "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=600&q=80",
            difficulty: "Easy",
            prepTime: 10,
            cookingTime: 20
        )
        let eitan2 = Recipe(
            title: "Fluffy Pancakes",
            author: "Eitan Bernath",
            imageURL: "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=600&q=80",
            prepTime: 15,
            cookingTime: 15
        )
        context.insert(eitan1)
        context.insert(eitan2)
        
        // 3. Cook This Tonight (Fast)
        let tonight1 = Recipe(
            title: "Lemon Garlic Pasta",
            author: "Chef John",
            imageURL: "https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?auto=format&fit=crop&w=600&q=80",
            difficulty: "Easy",
            cookingTime: 15
        )
        let tonight2 = Recipe(
            title: "Avocado Toast",
            author: "Healthy Eats",
            imageURL: "https://images.unsplash.com/photo-1588137372308-15f75323a399?auto=format&fit=crop&w=600&q=80",
            difficulty: "Easy",
            cookingTime: 5
        )
         context.insert(tonight1)
         context.insert(tonight2)
        
        // 4. Saved Videos
        let video1 = Recipe(
            title: "How to make Sushi",
            author: "Sushi Master",
            sourceLink: "https://youtube.com/watch?v=12345",
            imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=600&q=80",
            cookingTime: 60
        )
        let video2 = Recipe(
            title: "Best Burger Tutorial",
            author: "Burger King",
             sourceLink: "https://tiktok.com/@burgerking/video/123456",
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80",
            cookingTime: 30
        )
        context.insert(video1)
        context.insert(video2)
        
        do {
            try context.save()
            print("✅ Seeding complete.")
        } catch {
            print("❌ Seeding failed: \(error)")
        }
    }
}
