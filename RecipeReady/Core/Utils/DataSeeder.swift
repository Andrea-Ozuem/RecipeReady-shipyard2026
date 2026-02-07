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
        // We need to create NEW instances because SwiftData objects are reference types and bound to context on insert
        let featured = SampleData.featured
        context.insert(featured)
        
        // 2. Eitan's Kitchen
        for recipe in SampleData.eitanRecipes {
            context.insert(recipe)
        }
        
        // 3. Cook This Tonight (Fast)
        for recipe in SampleData.tonightRecipes {
            context.insert(recipe)
        }
        
         // 4. Saved Videos
        for recipe in SampleData.videoRecipes {
            context.insert(recipe)
        }
        
        do {
            try context.save()
            print("✅ Seeding complete.")
        } catch {
            print("❌ Seeding failed: \(error)")
        }
    }
}
