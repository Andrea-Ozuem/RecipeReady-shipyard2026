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
        // 1. cleanupDuplicates (Fix for the bug where recipes appeared twice)
        cleanupDuplicates(context: context)

        // 2. Check if specific static recipes exist, and add if missing
        // We do typically want to ensure Eitan's recipes are there, but only once.
        
        let staticRecipes = SampleData.eitanStaticRecipes
        for staticRecipe in staticRecipes {
            ensureRecipeExists(staticRecipe, context: context)
        }
        
        // 3. Featured: Only add if absolutely no recipes exist? 
        // Or check specifically for the featured one? 
        // Existing logic was "if count > 0 return". 
        // Let's preserve the "Hero" logic safely: Only add "Casseroles" if it's missing AND we think it should be there.
        // But the user requested to REMOVE "Casseroles" in a previous task. 
        // So we should actually NOT seed "Casseroles" / "Featured" anymore if the user wants it gone.
        // To be safe and respect "Remove Static Recipe" intent, I will NOT force-seed the 'featured' recipe again.
        
        do {
            try context.save()
            print("✅ Seeding check complete.")
        } catch {
            print("❌ Seeding failed: \(error)")
        }
    }
    
    private static func ensureRecipeExists(_ recipe: Recipe, context: ModelContext) {
        let title = recipe.title
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.title == title }
        )
        do {
            let count = try context.fetchCount(descriptor)
            if count == 0 {
                print("Inserting missing static recipe: \(title)")
                context.insert(recipe)
            }
        } catch {
            print("Error checking existence for \(title): \(error)")
        }
    }
    
    private static func cleanupDuplicates(context: ModelContext) {
        // Fetch all recipes authored by Eitan
        // Note: Predicate support for "contains" might be tricky in pure SwiftData depending on version, 
        // but exact match for known titles is safer.
        
        let staticTitles = SampleData.eitanStaticRecipes.map { $0.title }
        
        for title in staticTitles {
            let descriptor = FetchDescriptor<Recipe>(
                predicate: #Predicate { $0.title == title }
            )
            do {
                var recipes = try context.fetch(descriptor)
                if recipes.count > 1 {
                    print("Found \(recipes.count) duplicates for '\(title)'. Removing extras...")
                    // Keep the first one, delete the rest
                    // Sort by creation date if possible? Or just arbitrary.
                    // recipes.sort { $0.createdAt < $1.createdAt } // Assuming Recipe has createdAt
                    
                    for i in 1..<recipes.count {
                        context.delete(recipes[i])
                    }
                }
            } catch {
                print("Error deduplicating \(title): \(error)")
            }
        }
    }
}
