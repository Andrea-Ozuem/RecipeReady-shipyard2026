//
//  ShoppingListView.swift
//  RecipeReady
//
//  Created for Shopping List implementation.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var recipeForOptions: ShoppingListRecipe?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("Shopping List")
                        .font(.largeTitle)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Temporary button to toggle state for testing
                        Button(action: {
                            withAnimation {
                                viewModel.toggleMockData()
                            }
                        }) {
                            Image(systemName: "flask") // Science flask for "Testing"
                                .font(.system(size: 20))
                                .foregroundColor(.textSecondary)
                        }
                        
                        // Trash Button
                        Button(action: {
                            // TODO: Clear list action
                            withAnimation {
                                viewModel.recipes.removeAll()
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24) // Spacing between header and content
                
                if viewModel.isEmpty {
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    // Populated State
                    VStack(spacing: 0) {
                        // Tab Switcher
                        HStack(spacing: 0) {
                            tabButton(title: "Recipes (\(viewModel.recipes.count))", tab: .recipes)
                            tabButton(title: "All items", tab: .allItems)
                        }
                        
                        Divider()
                            .overlay(Color.divider)
                        
                        // List Content
                        if viewModel.selectedTab == .recipes {
                            List {
                                ForEach($viewModel.recipes) { $recipe in
                                    VStack(spacing: 0) {
                                        ShoppingListRecipeRow(
                                            recipe: recipe,
                                            onToggleExpand: {
                                                viewModel.toggleExpansion(for: recipe.id)
                                            },
                                            onMoreTap: {
                                                recipeForOptions = recipe
                                            }
                                        )
                                        .padding(.horizontal, 20)
                                        
                                        if recipe.isExpanded {
                                            ShoppingListExpandedView(recipe: $recipe, viewModel: viewModel)
                                                .padding(.bottom, 12)
                                        }
                                        
                                        if viewModel.recipes.last?.id != recipe.id {
                                             Divider()
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets()) // Padding handled internally now because expanded view needs full width
                                }
                            }
                            .listStyle(.plain)
                        } else {
                            // All Items Tab
                            ZStack(alignment: .bottom) {
                                List {
                                    ForEach(viewModel.allIngredients) { ingredient in
                                        ShoppingListIngredientRow(ingredient: ingredient) {
                                            viewModel.toggleAllIngredientsItem(id: ingredient.id)
                                        }
                                        .listRowSeparator(.hidden)
                                    }
                                }
                                .listStyle(.plain)
                                
                                // Floating Action Button
                                Button(action: {
                                    withAnimation {
                                        viewModel.unmarkAll()
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
                                // TODO: Navigate to recipe
                                recipeForOptions = nil
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "square.and.arrow.up") // Using share icon as placeholder or external link icon if more appropriate "arrow.up.right"
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
                                viewModel.removeRecipe(id: recipe.id)
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
        }
    }
    
    // MARK: - Components or Helpers
    
    private func tabButton(title: String, tab: ShoppingListViewModel.Tab) -> some View {
        Button(action: {
            withAnimation {
                viewModel.selectedTab = tab
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.bodyRegular)
                    .foregroundStyle(viewModel.selectedTab == tab ? Color.primaryOrange : Color.textPrimary)
                
                // Active Indicator
                Rectangle()
                    .fill(viewModel.selectedTab == tab ? Color.primaryOrange : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration
            // Using a system image as a placeholder for now as discussed
            Image(systemName: "cart.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.primaryOrange.opacity(0.8))
                .padding(.bottom, 16)
            
            VStack(spacing: 12) {
                Text("You don't have recipes on your shopping list yet.")
                    .font(.heading1)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal,30) // More padding for title
                
                Text("When you add ingredients to your shopping list, you'll see them here! Happy shopping!")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15) // Less padding for body
            }
            
            Spacer()
            Spacer() // Push content slightly up
        }
        .padding() // Default padding for container
    }
}

#Preview {
    ShoppingListView()
}
