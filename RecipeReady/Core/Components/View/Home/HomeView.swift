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
                            .font(.bodyBold)
                            .foregroundColor(.primaryOrange)
                            .padding(.horizontal, 30) // Add padding to align with content
                            .padding(.vertical, 20)
                        
                        // Underline
                        Rectangle()
                            .fill(Color.primaryOrange)
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
                    
                    if !viewModel.eitanRecipes.isEmpty {
                        HomeSection(title: "From Eitan's Kitchen", recipes: viewModel.eitanRecipes)
                    }
                    
                    if !viewModel.tonightRecipes.isEmpty {
                        HomeSection(title: "Cook This Tonight", recipes: viewModel.tonightRecipes)
                    }
                    
                    if !viewModel.videoRecipes.isEmpty {
                        HomeSection(title: "From Your Saved Videos", recipes: viewModel.videoRecipes)
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
                .foregroundColor(.primaryOrange)
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
