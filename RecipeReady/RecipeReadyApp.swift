//
//  RecipeReadyApp.swift
//  RecipeReady
//
//  Created by Ozuem Andrea Chukwunomswe  on 31/01/2026.
//

import SwiftUI
import SwiftData

@main
struct RecipeReadyApp: App {
    @State private var extractionManager = ExtractionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(extractionManager)
                .onOpenURL { url in
                    extractionManager.handleURL(url)
                }
                .onAppear {
                    extractionManager.checkForPendingExtraction()
                }
        }
        .modelContainer(for: [Recipe.self, Cookbook.self, ShoppingListRecipe.self, ShoppingListItem.self])
    }
    
}