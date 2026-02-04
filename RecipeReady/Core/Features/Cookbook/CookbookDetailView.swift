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
    let cookbook: CookbookItem
    
    // In a real app, we'd query recipes filtered by this cookbook.
    // For now, we show all mock recipes.
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    
    @State private var isShowingEditSheet = false
    
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
                .padding(.top, 10)
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
                    Text(cookbook.title)
                        .font(.heading1)
                        .foregroundColor(.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.textPrimary)
                        }
                        Button(action: {
                            isShowingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditCookbookSheet(
                    cookbook: cookbook,
                    onSave: { newTitle in
                        // TODO: Update title in parent/model
                        print("Saved title: \(newTitle)")
                    },
                    onDelete: {
                        // TODO: Delete action
                        print("Deleted cookbook")
                        dismiss()
                    }
                )
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    CookbookDetailView(cookbook: CookbookItem(title: "Salad", count: 4, imageURLs: [
        "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80",
        "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500&q=80",
        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80"
    ]))
        .modelContainer(for: Recipe.self, inMemory: true)
}
