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
        NavigationStack {
            // For UI-First dev, we directly show the Detail View with Mock Data
            RecipeDetailView(recipe: .mock)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
