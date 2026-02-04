//
//  CookbookDetailView.swift
//  RecipeReady
//
//  Displays the recipes within a specific cookbook.
//

import SwiftUI
import SwiftData

struct CookbookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    
    // In a real app, we'd query recipes filtered by this cookbook.
    // For now, we show all mock recipes.
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    
    // Grid Setup
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack { // Inner stack for preview/structure, though parent handles nav
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    // Using mock data multiple times to fill the grid for demo
                    ForEach(0..<4, id: \.self) { _ in
                         RecipeCardView(recipe: .mock)
                    }
                    // Also show any real persisted recipes
                    ForEach(recipes) { recipe in
                        RecipeCardView(recipe: recipe)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, -20)
            }
            .background(Color.screenBackground)
            .navigationBarBackButtonHidden(true) // Custom back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.heading1)
                        .foregroundColor(.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.textPrimary)
                        }
                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CookbookDetailView(title: "Salad")
        .modelContainer(for: Recipe.self, inMemory: true)
}
