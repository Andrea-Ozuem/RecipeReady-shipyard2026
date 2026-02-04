//
//  RecipeDetailView.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    // State for local interactions
    @State private var currentServings: Int = 4
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Hero Image
                    // Placeholder or AsyncImage
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .foregroundColor(.gray)
                        )
                        .frame(height: 300)
                        .clipped()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Metadata Section (Difficulty & Times)
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // Difficulty Row
                            if let difficulty = recipe.difficulty {
                                HStack(alignment: .center, spacing: 4) {
                                    Text("Difficulty:")
                                        .font(.bodyBold)
                                        .foregroundColor(.textPrimary)
                                    Text(difficulty)
                                        .font(.bodyRegular)
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                }
                            }
                            
                            Divider()
                                .foregroundColor(Color.divider)
                            
                            // Time Circles Row
                            HStack(spacing: 0) {
                                if let prep = recipe.prepTime {
                                    TimeCircleView(title: "Preparation", minutes: prep)
                                    Spacer()
                                }
                                
                                if let bake = recipe.bakingTime {
                                    TimeCircleView(title: "Baking", minutes: bake)
                                    Spacer()
                                }
                                
                                if let rest = recipe.restingTime {
                                    TimeCircleView(title: "Resting", minutes: rest)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 16)
                        
                        Divider()
                            .foregroundColor(Color.divider)
                        
                        // MARK: - Ingredients Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Ingredients")
                            
                            HStack {
                                Text("\(currentServings) Servings")
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                ServingsStepper(servings: $currentServings)
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(recipe.ingredients) { ingredient in
                                    IngredientRow(ingredient: ingredient)
                                }
                            }
                            .padding(.top, 8)
                            
                            // Add to shopping list Button
                            Button(action: {
                                // TODO: Shopping list action
                            }) {
                                HStack {
                                    Image(systemName: "cart")
                                    Text("Add to shopping list")
                                }
                                .font(.bodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.primaryGreen)
                                .cornerRadius(25) // Pill shape
                            }
                            .padding(.top, 16)
                        }
                        // Removed .horizontal padding here, applying it to container
                        
                        Divider()
                            // Removed horizontal padding here
                        
                        // MARK: - Instructions Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Instructions")
                            
                            VStack(spacing: 8) {
                                ForEach(recipe.steps.sorted(by: { $0.order < $1.order })) { step in
                                    InstructionRow(step: step)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.top, 16)
                        // Removed .padding(.horizontal, 20) to avoid double indentation
                        
                        // Start Cooking Button - Moved here after Instructions
                            Button(action: {
                                // TODO: Start cooking mode
                            }) {
                                Text("Start cooking!")
                                    .font(.bodyBold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.primaryGreen)
                                    .cornerRadius(25)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                    .padding(.horizontal, 20) // Apply horizontal padding to the content container, not the image
                }
            }
            .edgesIgnoringSafeArea(.top) // Allow ScrollView to go under nav bar
            
            // Custom Floating Header
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Share action
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.textPrimary)
                        .padding(10)
                        .background(Circle().fill(Color.white))
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                
                Button(action: {
                    // TODO: Favorite action
                }) {
                    Image(systemName: "heart")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.textPrimary)
                        .padding(10)
                        .background(Circle().fill(Color.white))
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            // No top padding: ZStack content respects safe area by default, putting this in standard Toolbar position.
        }
        .toolbar(.hidden, for: .navigationBar) // Completely hide system nav bar
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: .mock)
    }
}
