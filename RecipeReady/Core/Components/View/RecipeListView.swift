//
//  RecipeListView.swift
//  RecipeReady
//
//  Displays saved recipes in a list.
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    
    var body: some View {
        Group {
            if recipes.isEmpty {
                emptyState
            } else {
                recipeList
            }
        }
        .navigationTitle("Recipes")
    }
    
    // MARK: - Views
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Recipes Yet",
            systemImage: "fork.knife.circle",
            description: Text("Share a video from Instagram or TikTok to extract a recipe.")
        )
    }
    
    private var recipeList: some View {
        List {
            ForEach(recipes) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .onDelete(perform: deleteRecipes)
        }
    }
    
    // MARK: - Actions
    
    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
    }
}

// MARK: - Recipe Row

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.title)
                .font(.headline)
            
            HStack(spacing: 12) {
                Label("\(recipe.ingredients.count)", systemImage: "leaf")
                Label("\(recipe.steps.count) steps", systemImage: "list.number")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RecipeListView()
    }
    .modelContainer(for: Recipe.self, inMemory: true)
}
