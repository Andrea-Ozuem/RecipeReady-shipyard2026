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
    
    var body: some View {
        TabView {
            // Home Tab
            NavigationStack {
                CookbookView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            // Search Tab (Placeholder)
            Text("Search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            // Saved Tab (Placeholder)
            Text("Saved")
                .tabItem {
                    Label("Saved", systemImage: "heart")
                }
            
            // Shopping List Tab
            ShoppingListView()
                .tabItem {
                    Label("Shopping list", systemImage: "cart")
                }
            
            // Profile Tab (Placeholder)
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(.primaryGreen) // Use our brand color for active tab
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
