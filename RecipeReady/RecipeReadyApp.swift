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
                    seedDefaultCookbook()
                }
        }
        .modelContainer(for: [Recipe.self, Cookbook.self])
    }
    
    private func seedDefaultCookbook() {
        // We need a separate context or query here, but inside a View we usually rely on @Query.
        // However, for seeding once, we can use the main context if available environment.
        // But better pattern: checking via query in onAppear.
        // Let's do a simple check.
    }
}