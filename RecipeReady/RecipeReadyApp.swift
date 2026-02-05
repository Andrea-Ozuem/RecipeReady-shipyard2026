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
    
    // Model container with initialization
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Recipe.self, Cookbook.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Initialize favorites cookbook if it doesn't exist
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Cookbook>(
                predicate: #Predicate { $0.isFavorites == true }
            )
            
            if let existingFavorites = try? context.fetch(descriptor), existingFavorites.isEmpty {
                let favorites = Cookbook(
                    title: "My favourite recipes",
                    isFavorites: true
                )
                context.insert(favorites)
                try? context.save()
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
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
                .sheet(isPresented: $extractionManager.showingExtraction) {
                    ExtractionSheet()
                        .environment(extractionManager)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
