//
//  ContentView.swift
//  RecipeReady
//
//  Created by Ozuem Andrea Chukwunomswe  on 31/01/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // We keep the environments to avoid breaking the App entry point if it injects them
    @Environment(\.modelContext) private var modelContext
    @Environment(ExtractionManager.self) private var extractionManager

    @EnvironmentObject var navigationManager: NavigationManager

    @State private var recipeToOpen: Recipe?
    @State private var showRecipeDetail = false

    var body: some View {
        TabView(selection: $navigationManager.selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(NavigationManager.Tab.home)
            
            NavigationStack {
                CookbookView()
            }
            .tabItem {
                Label("Cookbooks", systemImage: "heart")
            }
            .tag(NavigationManager.Tab.cookbooks)
            
            // Grocery List Tab
            ShoppingListView()
                .tabItem {
                    Label("Grocery list", systemImage: "cart")
                }
                .tag(NavigationManager.Tab.groceryList)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(NavigationManager.Tab.profile)
        }
        .tint(.primaryBlue)
        .sheet(isPresented: Binding(
            get: { extractionManager.state != .idle },
            set: { if !$0 { extractionManager.dismiss() } }
        )) {
            ExtractionSheet()
        }
        .sheet(item: $recipeToOpen) { recipe in
            NavigationStack {
                RecipeDetailView(recipe: recipe)
            }
        }
        .onAppear {
            DataSeeder.seed(context: modelContext)
            setupNotificationListener()
        }
    }

    // MARK: - Notification Handling

    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("OpenRecipeFromNotification"),
            object: nil,
            queue: .main
        ) { notification in
            guard let recipeId = notification.userInfo?["recipeId"] as? UUID else { return }
            openRecipe(withId: recipeId)
        }
    }

    private func openRecipe(withId recipeId: UUID) {
        // Fetch the recipe from SwiftData
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { recipe in
                recipe.id == recipeId
            }
        )

        do {
            let recipes = try modelContext.fetch(descriptor)
            if let recipe = recipes.first {
                recipeToOpen = recipe
            }
        } catch {
            print("Error fetching recipe for notification: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, Cookbook.self], inMemory: true)
        .environment(ExtractionManager())
        .environmentObject(NavigationManager())
}
