//
//  FavoritesDetailView.swift
//  RecipeReady
//
//  Displays all recipes marked as favorites.
//

import SwiftUI
import SwiftData

struct FavoritesDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Recipe> { $0.isFavorite == true }, sort: \Recipe.title) private var favoriteRecipes: [Recipe]
    
    // Grid Setup
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header (Mimicking CookbookHeaderView style but simpler)
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color(hex: "FF6B35"))
                        .frame(height: 180)
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text("My favourite recipes")
                            .font(.display)
                            .foregroundColor(.white)
                        
                        Text("\(favoriteRecipes.count) recipes")
                            .font(.bodyRegular)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                
                // Content
                ScrollView {
                    if favoriteRecipes.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "heart.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.textSecondary)
                            Text("No favorites yet")
                                .font(.heading2)
                                .foregroundColor(.textPrimary)
                            Text("Mark recipes as favorites to see them here.")
                                .font(.bodyRegular)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Spacer()
                        }
                        .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(favoriteRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCard(recipe: recipe)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .background(Color.screenBackground)
            // Custom Toolbar for Back button
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.bodyBold)
                            .foregroundColor(.white) // White because header is orange
                            .padding(8)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}
