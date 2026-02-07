//
//  ShoppingListView.swift
//  RecipeReady
//
//  Created for Grocery List implementation.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [ShoppingListRecipe]
    
    @State private var recipeForOptions: ShoppingListRecipe?
    @State private var selectedTab: Tab = .recipes
    @State private var navigationPath = NavigationPath()
    @State private var showRecipeDetail = false
    @State private var limit: Int = 10 
    @State private var recipeIDToNavigate: UUID?
    
    enum Tab {
        case recipes
        case allItems
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("Grocery List")
                        .font(.display)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Trash Button (Clear All)
                        if !recipes.isEmpty {
                            Button(action: {
                                withAnimation {
                                    clearAll()
                                }
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24) // Spacing between header and content
                
                if recipes.isEmpty {
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    // Populated State
                    VStack(spacing: 0) {
                        // Tab Switcher
                        HStack(spacing: 0) {
                            tabButton(title: "Recipes (\(recipes.count))", tab: .recipes)
                            tabButton(title: "All items", tab: .allItems)
                        }
                        
                        Divider()
                            .overlay(Color.divider)
                        
                        // List Content
                        if selectedTab == .recipes {
                            List {
                                ForEach(recipes) { recipe in
                                    VStack(spacing: 0) {
                                        ShoppingListRecipeRow(
                                            recipe: recipe,
                                            onToggleExpand: {
                                                recipe.isExpanded.toggle()
                                            },
                                            onMoreTap: {
                                                recipeForOptions = recipe
                                            }
                                        )
                                        .padding(.horizontal, 20)
                                        
                                        if recipe.isExpanded {
                                            ShoppingListExpandedView(recipe: recipe)
                                                .padding(.bottom, 12)
                                        }
                                        
                                        if recipes.last?.id != recipe.id {
                                             Divider()
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteRecipe(recipe)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                        } else {
                            // All Items Tab
                            ZStack(alignment: .bottom) {
                                List {
                                    ForEach(allIngredients) { item in
                                        ShoppingListIngredientRow(ingredient: item) {
                                            item.isChecked.toggle()
                                        }
                                        .listRowSeparator(.hidden)
                                    }
                                }
                                .listStyle(.plain)
                                
                                // Floating Action Button
                                Button(action: {
                                    withAnimation {
                                        unmarkAll()
                                    }
                                }) {
                                    Text("Unmark all items")
                                        .font(.bodyRegular)
                                        .foregroundColor(Color.primaryGreen)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(
                                            Capsule()
                                                .stroke(Color.primaryGreen, lineWidth: 1)
                                                .background(Color.white.clipShape(Capsule()))
                                        )
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                                .padding(.bottom, 24)
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $recipeForOptions) { recipe in
                NavigationStack {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // Open Recipe
                            Button(action: {
                                navigateToRecipe(recipe)
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20))
                                        .foregroundColor(.textPrimary)
                                        .frame(width: 24)
                                    
                                    Text("Open the recipe")
                                        .font(.bodyRegular)
                                        .foregroundColor(.textPrimary)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Delete Recipe
                            Button(action: {
                                deleteRecipe(recipe)
                                recipeForOptions = nil
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20))
                                        .foregroundColor(.textPrimary)
                                        .frame(width: 24)
                                    
                                    Text("Delete recipe from the list")
                                        .font(.bodyRegular)
                                        .foregroundColor(.textPrimary)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.top, 16) // Spacing from grabber
                        .padding(.bottom, 24)
                        
                        Spacer()
                    }
                }
                 .presentationDetents([.fraction(0.2)])
                .presentationDragIndicator(.hidden)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                 RecipeDetailView(recipe: recipe)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var allIngredients: [ShoppingListItem] {
        recipes.flatMap { $0.items }
    }
    
    private func deleteRecipe(_ recipe: ShoppingListRecipe) {
        modelContext.delete(recipe)
    }
    
    private func clearAll() {
        for recipe in recipes {
            modelContext.delete(recipe)
        }
    }
    
    private func unmarkAll() {
        for recipe in recipes {
            for item in recipe.items {
                item.isChecked = false
            }
        }
    }

    private func navigateToRecipe(_ shoppingListRecipe: ShoppingListRecipe) {
        guard let originalID = shoppingListRecipe.originalRecipeID else { return }
        
        // Fetch the recipe from the model context
        let descriptor = FetchDescriptor<Recipe>(predicate: #Predicate { $0.id == originalID })
        if let recipe = try? modelContext.fetch(descriptor).first {
            recipeForOptions = nil // Dismiss sheet first
            
            // Short delay to allow sheet to dismiss before pushing navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                 navigationPath.append(recipe)
            }
        }
    }
    
    private func tabButton(title: String, tab: Tab) -> some View {
        Button(action: {
            withAnimation {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.bodyRegular)
                    .foregroundStyle(selectedTab == tab ? Color.primaryBlue : Color.textPrimary)
                
                // Active Indicator
                Rectangle()
                    .fill(selectedTab == tab ? Color.primaryBlue : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration
            Image(systemName: "cart.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.primaryBlue.opacity(0.8))
                .padding(.bottom, 16)
            
            VStack(spacing: 12) {
                Text("You don't have recipes on your Grocery List yet.")
                    .font(.heading3)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal,30)
                
                Text("When you add ingredients to your Grocery List, you'll see them here! Happy shopping!")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ShoppingListView()
        // Provide example model container for preview if possible
}
