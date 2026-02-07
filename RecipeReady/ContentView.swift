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
    
    var body: some View {
        TabView {
            // Home Tab
            // Home Tab
            HomeView()
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationStack {
                CookbookView()
            }
            .tabItem {
                Label("Cookbooks", systemImage: "heart")
            }
            
            // Grocery List Tab
            ShoppingListView()
                .tabItem {
                    Label("Grocery list", systemImage: "cart")
                }
            
            // Profile Tab (Placeholder)
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(.primaryBlue)
        .sheet(isPresented: Binding(
            get: { extractionManager.state != .idle },
            set: { if !$0 { extractionManager.dismiss() } }
        )) {
            ExtractionSheet()
        }
        .onAppear {
            DataSeeder.seed(context: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, Cookbook.self], inMemory: true)
        .environment(ExtractionManager())
}
