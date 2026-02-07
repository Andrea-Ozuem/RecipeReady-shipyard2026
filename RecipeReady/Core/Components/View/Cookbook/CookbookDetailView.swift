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
    @Environment(\.modelContext) private var modelContext
    let cookbook: Cookbook
    
    @State private var isShowingEditSheet = false
    @State private var isShowingSearch = false
    @State private var recipeToMove: Recipe?
    
    // Grid Setup
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    if cookbook.recipes.isEmpty {
                        // Optional empty state
                        Text("No recipes yet")
                            .font(.bodyRegular)
                            .foregroundColor(.textSecondary)
                            .gridCellColumns(2)
                            .padding(.top, 40)
                    } else {
                        // Sort by createdAt descending
                        let sortedRecipes = cookbook.recipes.sorted(by: { $0.createdAt > $1.createdAt })
                        
                        ForEach(sortedRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeCardView(
                                    recipe: recipe,
                                    onMove: {
                                        recipeToMove = recipe
                                    },
                                    onDelete: {
                                        delete(recipe)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.screenBackground)
            .navigationBarBackButtonHidden(true) // Custom back button
            .toolbarBackground(Color.clear, for: .navigationBar) // User suggested fix for white pills
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
                    Text(cookbook.name)
                        .font(.heading1)
                        .foregroundColor(.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            isShowingSearch = true
                        }) {
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
                        cookbook.name = newTitle
                    },
                    onDelete: {
                        modelContext.delete(cookbook)
                        dismiss()
                    }
                )
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $isShowingSearch) {
                RecipeSearchView()
            }
            .sheet(item: $recipeToMove) { recipe in
                AddToCookbookSheet(recipe: recipe, moveFromCookbook: cookbook)
                    .presentationDetents([.medium, .large])
            }
    }
    
    private func delete(_ recipe: Recipe) {
        if let index = cookbook.recipes.firstIndex(where: { $0.id == recipe.id }) {
            withAnimation {
                cookbook.recipes.remove(at: index)
                // Optional: If you want to delete the recipe entirely from the app if it's not in any other cookbook,
                // you'd need more complex logic. For now, we assume "Delete" in the context of a cookbook means removing it from that cookbook.
                // However, if this is the "Main" list or "My Recipes", usage might vary.
                // Given the prompt "for recipies in cookbook", removing from cookbook is the safest interpretation unless specified otherwise.
            }
        }
    }
}

#Preview {
    CookbookDetailView(cookbook: Cookbook(name: "Salad", recipes: []))
        .modelContainer(for: [Recipe.self, Cookbook.self], inMemory: true)
}
