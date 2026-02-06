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
                                .font(.system(size: 20, weight: .bold))
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
                        Text("Search by ingredients")
                            .font(.heading1)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 10) // Align roughly with image bottom
                        
                        Spacer()
                        
                        Image(systemName: "takeoutbag.and.cup.and.straw.fill") // Closest SF Symbol to "jar & cup with straw" / food containers
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60) // Larger size for illustration
                            .foregroundColor(.primaryOrange)
                            .opacity(0.9)
                            .padding(.bottom, -10) // Slight overlap or alignment fix
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 60) // Increased space for larger header height
                }
                .background(Color.softBeige.ignoresSafeArea(edges: .top))
                .zIndex(0)
                
                // MARK: - Search Bar (Overlapping)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textSecondary)
                    
                    TextField("Type an ingredient", text: $viewModel.searchText)
                        .font(.bodyRegular)
                        .foregroundColor(.textPrimary)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    // Heart icon inside search bar
                    Button(action: {
                        // Action for favourites
                    }) {
                        Image(systemName: "heart")
                            .font(.system(size: 20))
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .frame(height: 56) // Fixed height to ensure consistent overlap calculation
                .offset(y: -28) // Pull up by half height
                .padding(.bottom, -28) // Remove the space it occupied in the flow
                .zIndex(1) // Ensure it sits on top of both backgrounds
                
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
                                    Text("\(viewModel.selectedIngredients.count) out of 4 ingredients") // Mock count
                                        .font(.heading2)
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Button("See all") {
                                        // See all action
                                    }
                                    .font(.bodyRegular)
                                    .foregroundColor(.primaryOrange)
                                }
                                .padding(.horizontal)
                                
                                // Chips for matched ingredients (Mock for now, or reuse selected)
                                // The design shows them here too? Or maybe just recipe cards. 
                                // Let's stick to the Recipe Cards scroll for now as per plan.
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        // Mock Results
                                        RecipeResultCard(
                                            recipeTitle: "Homemade Lasagna",
                                            time: "70 min.",
                                            imageURL: nil
                                        )
                                        
                                        RecipeResultCard(
                                            recipeTitle: "Pan-Seared Salmon",
                                            time: "30 min.",
                                            imageURL: nil
                                        )
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        } else {
                            // 4. Default / Favourites Section (when nothing selected)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("My favourite ingredients")
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("Access your favourites easily! Click the ♡-icon in the search field to save your favourite ingredients.")
                                    .font(.captionMeta)
                                    .foregroundColor(.textSecondary)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal)
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
    }
}

#Preview {
    RecipeSearchView()
}
