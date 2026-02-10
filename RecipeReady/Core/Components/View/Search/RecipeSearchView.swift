//
//  RecipeSearchView.swift
//  RecipeReady
//
//  Main view for searching recipes by ingredients.
//

import SwiftUI

struct RecipeSearchView: View {
    @StateObject private var viewModel = RecipeSearchViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    /// Optional cookbook to scope the search to only its recipes
    let cookbook: Cookbook?

    init(cookbook: Cookbook? = nil) {
        self.cookbook = cookbook
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Header Section (Beige)
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.iconRegular)
                                .foregroundColor(.textPrimary)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Title and Illustration
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Search by ingredients")
                                .font(.heading1)
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.leading)

                            if let cookbook = cookbook {
                                Text("in \(cookbook.name)")
                                    .font(.bodyRegular)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(.bottom, 10) // Align roughly with image bottom
                        
                        Spacer()
                        
                        Image(systemName: "takeoutbag.and.cup.and.straw.fill") // Closest SF Symbol to "jar & cup with straw" / food containers
                            .resizable()
                            .scaledToFit()
                            .fontWeight(.light) // Consistent weight
                            .frame(width: 60, height: 60) // Larger size for illustration
                            .foregroundColor(.primaryBlue)
                            .opacity(0.9)
                            .padding(.bottom, -10) // Slight overlap or alignment fix
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 60) // Increased space for larger header height
                }
                .background(Color.softBeige.ignoresSafeArea(edges: .top))
                .zIndex(0)
                
                // MARK: - Search Bar & Dropdown Container
                VStack(spacing: 0) {
                    // Search Input Row
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.iconRegular)
                            .foregroundColor(.textSecondary)
                        
                        TextField("Type an ingredient", text: $viewModel.searchText)
                            .font(.bodyRegular)
                            .foregroundColor(.textPrimary)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark")
                                    .font(.iconRegular)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    .padding()
                    .frame(height: 56)
                    
                    // Dropdown List (Visible when typing)
                    if !viewModel.searchText.isEmpty {
                        Divider()
                            .background(Color.divider)
                        
                        ForEach(viewModel.filteredIngredients.prefix(5), id: \.self) { ingredient in
                            VStack(spacing: 0) {
                                SearchSuggestionRow(
                                    name: ingredient,
                                    isFavorite: viewModel.isFavorite(ingredient),
                                    onSelect: {
                                        viewModel.toggleIngredient(ingredient)
                                    },
                                    onToggleFavorite: {
                                        viewModel.toggleFavorite(ingredient)
                                    }
                                )
                                
                                if ingredient != viewModel.filteredIngredients.prefix(5).last {
                                    Divider()
                                        .background(Color.divider)
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                // Layout Adjustments to handle expansion
                .offset(y: -28) 
                .padding(.bottom, -28) // Remove space
                // .padding(.bottom, 20) // Removed extra padding here to keep overlap tight
                .zIndex(1) // Keep on top
                
                // Overlay background dimming if searching (Optional, based on design "focus" state)
                .shadow(color: Color.black.opacity(viewModel.searchText.isEmpty ? 0 : 0.1), radius: 10, x: 0, y: 5)
                
                // MARK: - Content Section (White)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 1. Selected Ingredients Row (if any)
                        if !viewModel.selectedIngredients.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.sortedSelectedIngredients, id: \.self) { ingredient in
                                        IngredientTag(
                                            name: ingredient,
                                            isSelected: true,
                                            action: {
                                                viewModel.toggleIngredient(ingredient)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // 2. Suggested Ingredients (Scrollable Grid)
                        // Only show if we haven't selected everything or if design always shows suggestions below
                        if !viewModel.filteredIngredients.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 8) {
                                    let ingredients = viewModel.filteredIngredients
                                    // simple chunking
                                    let firstRow = ingredients.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
                                    let secondRow = ingredients.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }
                                    
                                    HStack(spacing: 8) {
                                        ForEach(firstRow, id: \.self) { ingredient in
                                            IngredientTag(
                                                name: ingredient,
                                                isSelected: false,
                                                action: {
                                                    viewModel.toggleIngredient(ingredient)
                                                }
                                            )
                                        }
                                    }
                                    
                                    if !secondRow.isEmpty {
                                        HStack(spacing: 8) {
                                            ForEach(secondRow, id: \.self) { ingredient in
                                                IngredientTag(
                                                    name: ingredient,
                                                    isSelected: false,
                                                    action: {
                                                        viewModel.toggleIngredient(ingredient)
                                                    }
                                                )
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 100) // Keep the constraint for the grid area
                        }
                        
                        // 3. Results Section (Show only if ingredients selected)
                        if !viewModel.selectedIngredients.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("\(viewModel.searchResults.count) recipe\(viewModel.searchResults.count == 1 ? "" : "s") found")
                                        .font(.heading2)
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                if viewModel.searchResults.isEmpty {
                                    // Empty state
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 40))
                                            .foregroundColor(.textSecondary)
                                        Text("No recipes found")
                                            .font(.bodyBold)
                                            .foregroundColor(.textPrimary)
                                        Text("Try removing an ingredient or searching for different combinations.")
                                            .font(.captionMeta)
                                            .foregroundColor(.textSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    // Actual search results
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(viewModel.searchResults) { recipe in
                                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                                    RecipeResultCard(
                                                        recipeTitle: recipe.title,
                                                        time: recipe.cookingTime.map { "\($0) min" } ?? "—",
                                                        imageURL: recipe.imageURL
                                                    )
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                .zIndex(0)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadData(context: modelContext, cookbook: cookbook)
        }
    }
}

#Preview {
    RecipeSearchView()
}
