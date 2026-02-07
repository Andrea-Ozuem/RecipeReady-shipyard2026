//
//  HomeView.swift
//  RecipeReady
//
//  Main application home screen.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
                VStack(spacing: 0) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recipe Ready")
                            .font(.absans(size: 24))
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal, 20) // Add padding to align with content
                            .padding(.vertical, 5)
                        
                        // Underline
                        Rectangle()
                            .fill(Color.primaryBlue)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.screenBackground)
                    
                    ScrollView {
                        VStack(spacing: 32) {
                    // MARK: - Hero
                    if let featured = viewModel.featuredRecipe {
                        LargeFeaturedCard(recipe: featured)
                            .onTapGesture {
                                // Navigate to Detail
                            }
                    }
                    
                    // MARK: - Sections
                    
                    HomeSection(title: "From Eitan's Kitchen", recipes: viewModel.eitanRecipes)
                    
                    HomeSection(title: "Cook This Tonight", recipes: viewModel.tonightRecipes)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("From Your Saved Videos")
                            .font(.heading2)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                        
                        if !viewModel.videoRecipes.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.videoRecipes) { recipe in
                                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                            RecipeCard(recipe: recipe)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    Image(systemName: "video.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(.textSecondary)
                                    Text("No saved videos yet")
                                        .font(.bodyBold)
                                        .foregroundColor(.textPrimary)
                                    Text("Extract recipes from videos to see them here.")
                                        .font(.captionMeta)
                                        .foregroundColor(.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 40)
                                .padding(.horizontal, 20)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.screenBackground)
            .ignoresSafeArea(edges: .top)
            .onAppear {
                viewModel.refresh(recipes: recipes)
            }
            .onChange(of: recipes) { oldValue, newValue in
                viewModel.refresh(recipes: newValue)
            }
        }
    }
}
}

// MARK: - Helper Section Component
struct HomeSection: View {
    let title: String
    let recipes: [Recipe]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("See all") {
                    // Action
                }
                .font(.bodyRegular)
                .foregroundColor(.primaryBlue)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCard(recipe: recipe)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Recipe.self, Cookbook.self, ShoppingListRecipe.self, ShoppingListItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        DataSeeder.seed(context: container.mainContext)
        return container
    } catch {
        fatalError("Failed to create preview container: \(error)")
    }
}()

#Preview {
    HomeView()
        .modelContainer(previewContainer)
}
