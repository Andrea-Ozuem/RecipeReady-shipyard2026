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
                        
                        // Illustration placeholder
                        Image(systemName: "basket.fill") // Placeholder for illustration
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.primaryOrange)
                            .opacity(0.8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Title
                    HStack {
                        Text("Search by ingredients")
                            .font(.heading1)
                            .foregroundColor(.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.bottom, 10)
                    
                    // Search Bar
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
                        
                        // Heart icon inside search bar (right side)
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
                    .padding(.bottom, -26) // Half-overlap effect or just resting on edge
                    .zIndex(1) // Ensure search bar sits on top
                }
                .padding(.bottom, 26) // Space for the overlapping search bar
                .background(Color.softBeige.ignoresSafeArea(edges: .top))
                
                // MARK: - Content Section (White)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Ingredient Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 8) {
                                // Split ingredients into two rows
                                let ingredients = viewModel.filteredIngredients
                                let firstRow = ingredients.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
                                let secondRow = ingredients.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }
                                
                                HStack(spacing: 8) {
                                    ForEach(firstRow, id: \.self) { ingredient in
                                        IngredientTag(
                                            name: ingredient,
                                            isSelected: viewModel.isSelected(ingredient),
                                            action: {
                                                viewModel.toggleIngredient(ingredient)
                                            }
                                        )
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    ForEach(secondRow, id: \.self) { ingredient in
                                        IngredientTag(
                                            name: ingredient,
                                            isSelected: viewModel.isSelected(ingredient),
                                            action: {
                                                viewModel.toggleIngredient(ingredient)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        // Constrain height loosely to fit 2 rows + spacing (approx 36-40 per tag + 8 spacing = ~90)
                        .frame(height: 100)
                        
                        // Favourites Section
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
                    .padding(.top, 20) // Space from the search bar
                    .padding(.bottom, 20)
                }
                .background(Color.white)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    RecipeSearchView()
}
