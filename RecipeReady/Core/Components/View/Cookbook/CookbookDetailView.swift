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
    @State private var isSearching = false
    @State private var searchQuery = ""
    @State private var isShowingIngredientSearch = false
    @State private var recipeToMove: Recipe?

    // Grid Setup
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // Filtered recipes based on search query
    private var filteredRecipes: [Recipe] {
        let sorted = cookbook.recipes.sorted(by: { $0.createdAt > $1.createdAt })

        guard !searchQuery.isEmpty else {
            return sorted
        }

        return sorted.filter { recipe in
            // Search in title
            if recipe.title.localizedCaseInsensitiveContains(searchQuery) {
                return true
            }

            // Search in ingredients
            if recipe.ingredients.contains(where: { $0.name.localizedCaseInsensitiveContains(searchQuery) }) {
                return true
            }

            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar and ingredient filter (conditionally shown)
            if isSearching {
                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.iconRegular)
                            .foregroundColor(.textSecondary)

                        TextField("Search recipes...", text: $searchQuery)
                            .font(.bodyRegular)
                            .foregroundColor(.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                        if !searchQuery.isEmpty {
                            Button(action: {
                                searchQuery = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.iconRegular)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.divider),
                        alignment: .bottom
                    )

                    // Ingredient filter button
                    HStack(spacing: 8) {
                        Button(action: {
                            isShowingIngredientSearch = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "basket")
                                    .font(.iconSmall)
                                Text("Ingredients")
                                    .font(.bodyRegular)
                                Image(systemName: "chevron.down")
                                    .font(.iconSmall)
                            }
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.divider, lineWidth: 1)
                            )
                            .cornerRadius(20)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.screenBackground)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    if cookbook.recipes.isEmpty {
                        // Empty cookbook state
                        Text("No recipes yet")
                            .font(.bodyRegular)
                            .foregroundColor(.textSecondary)
                            .gridCellColumns(2)
                            .padding(.top, 40)
                    } else if filteredRecipes.isEmpty {
                        // No search results state
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.textSecondary)
                            Text("No recipes found")
                                .font(.bodyBold)
                                .foregroundColor(.textPrimary)
                            Text("Try a different search term")
                                .font(.captionMeta)
                                .foregroundColor(.textSecondary)
                        }
                        .gridCellColumns(2)
                        .padding(.top, 60)
                    } else {
                        ForEach(filteredRecipes) { recipe in
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
        }
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
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isSearching.toggle()
                                if !isSearching {
                                    searchQuery = ""
                                }
                            }
                        }) {
                            Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                                .font(.iconRegular)
                                .foregroundColor(.textPrimary)
                        }

                        Button(action: {
                            isShowingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.iconRegular)
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

            .sheet(item: $recipeToMove) { recipe in
                AddToCookbookSheet(recipe: recipe, moveFromCookbook: cookbook)
                    .presentationDetents([.medium, .large])
            }
            .fullScreenCover(isPresented: $isShowingIngredientSearch) {
                RecipeSearchView(cookbook: cookbook)
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
