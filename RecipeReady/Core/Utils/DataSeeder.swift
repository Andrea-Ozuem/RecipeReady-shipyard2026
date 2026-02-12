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
        // Centralized seeding logic for Eitan Eats the World static cookbook
        
        do {
            // 1. Ensure the Static Cookbook exists
            let cookbookRequest = FetchDescriptor<Cookbook>(
                predicate: #Predicate { $0.name == "Eitan Eats the world" }
            )
            let cookbooks = try context.fetch(cookbookRequest)
            
            let eitanCookbook: Cookbook
            if let existing = cookbooks.first {
                eitanCookbook = existing
                // Ensure it's marked static just in case
                if eitanCookbook.isStatic != true {
                    eitanCookbook.isStatic = true
                }
            } else {
                print("Creating Static Cookbook 'Eitan Eats the world'")
                eitanCookbook = Cookbook(
                    name: "Eitan Eats the world",
                    coverColor: "#FF6B35",
                    isStatic: true
                )
                context.insert(eitanCookbook)
            }
            
            // 2. Ensure all static recipes exist and are linked
            let staticRecipes = SampleData.eitanStaticRecipes
            var cookbookWasModified = false
            
            for staticRecipe in staticRecipes {
                let title = staticRecipe.title
                
                // Check if this recipe already exists in the DB
                let recipeRequest = FetchDescriptor<Recipe>(
                    predicate: #Predicate { $0.title == title }
                )
                let existingRecipes = try context.fetch(recipeRequest)
                
                let recipeToUse: Recipe
                
                if let existing = existingRecipes.first {
                    // Recipe exists, use it
                    recipeToUse = existing
                    
                    // Deduplicate if needed (if multiple found)
                    if existingRecipes.count > 1 {
                        print("Found duplicates for \(title), cleaning up...")
                        for i in 1..<existingRecipes.count {
                            context.delete(existingRecipes[i])
                        }
                    }
                } else {
                    // Recipe doesn't exist, create it
                    print("Inserting missing static recipe: \(title)")
                    context.insert(staticRecipe)
                    recipeToUse = staticRecipe
                }
                
                // 3. Ensure linkage to the cookbook
                // Check if this recipe is already in the cookbook's recipes list
                // We utilize the relationship. Note: 'eitanCookbook.recipes' is [Recipe]
                
                if !eitanCookbook.recipes.contains(where: { $0.id == recipeToUse.id }) {
                    print("Linking \(title) to Eitan's cookbook")
                    eitanCookbook.recipes.append(recipeToUse)
                    cookbookWasModified = true
                }
            }
            
            if cookbookWasModified || context.hasChanges {
                try context.save()
                print("✅ DataSeeder completed successfully.")
            }
            
        } catch {
            print("❌ DataSeeder failed: \(error)")
        }
    }
}
