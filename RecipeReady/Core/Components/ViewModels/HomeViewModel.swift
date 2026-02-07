//
//  HomeViewModel.swift
//  RecipeReady
//
//  Logic for Home screen data presentation.
//

import SwiftUI
import SwiftData

@Observable
class HomeViewModel {
    var featuredRecipe: Recipe?
    var eitanRecipes: [Recipe] = []
    var tonightRecipes: [Recipe] = []
    var videoRecipes: [Recipe] = []
    
    // We can't use @Query directly in a class reliably without ModelContext in init or passed in.
    // Easier pattern for SwiftData in ViewModel: pass the context or the array from View.
    // OR: Logic to filter the array passed from the View.
    
    init() {
        self.featuredRecipe = SampleData.featured
        self.eitanRecipes = SampleData.eitanRecipes
        self.tonightRecipes = SampleData.tonightRecipes
    }
    
    func refresh(recipes: [Recipe]) {
        // 1. Featured
        // Pick one marked isFeatured, or random. If none, use SampleData.
        if let found = recipes.first(where: { $0.isFeatured }) ?? recipes.randomElement() {
            self.featuredRecipe = found
        } else {
            self.featuredRecipe = SampleData.featured
        }
        
        // 2. Eitan's Kitchen
        let eitan = recipes.filter { $0.author?.contains("Eitan") == true }
        self.eitanRecipes = eitan.isEmpty ? SampleData.eitanRecipes : eitan
        
        // 3. Cook This Tonight (Fast recipes? < 30 mins)
        let tonight = recipes.filter { ($0.cookingTime ?? 999) <= 30 }
        self.tonightRecipes = tonight.isEmpty ? SampleData.tonightRecipes : tonight
        
        // 4. Saved Videos (Recipes with videoURL or sourceLink containing "youtube", "tiktok", etc? Or manual flag?)
        // For now, let's assume if it has a sourceLink it might be a video, or we add a specific check.
        // User said "User-imported video recipes (your core feature!)".
        // Core feature is extraction. So maybe recently extracted?
        // Let's filter by those having a sourceLink for now, or recently created.
        self.videoRecipes = recipes.filter { $0.sourceLink != nil }
    }
}
