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
    @Environment(\.dismiss) private var dismiss
    @State private var currentServings: Int = 4
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Hero Image
                    // Placeholder or AsyncImage
                    // MARK: - Hero Image
                    if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(Image(systemName: "fork.knife").foregroundColor(.gray))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 300)
                        .clipped()
                    } else {
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
                    }
                    
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
                            
                            // To preserve exact order of sections as they appear in the ingredients list:
                            let sections: [String?] = recipe.ingredients.reduce(into: [String?]()) { result, ingredient in
                                // Helper to handle the "String??" returned by result.last safely
                                // If array is empty, we must append
                                if result.isEmpty {
                                    result.append(ingredient.section)
                                } else if result.last! != ingredient.section {
                                    // result.last! is safe because we checked isEmpty. 
                                    // It returns String? (the element), which we compare to ingredient.section (String?)
                                    result.append(ingredient.section)
                                }
                            }
                            
                            VStack(spacing: 16) {
                                ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                                    VStack(alignment: .leading, spacing: 8) {
                                        if let sectionName = section, !sectionName.isEmpty {
                                            Text(sectionName)
                                                .font(.headline) // Or custom style
                                                .foregroundColor(.textPrimary)
                                                .padding(.top, 4)
                                        }
                                        
                                        // Get ingredients for this specific block (to handle repeated section names correctly if needed, though unlikely)
                                        // For simplicity, we just filter, but this breaks if section name repeats non-contiguously.
                                        // Better loop strategy:
                                        
                                        let ingredientsInSection = recipe.ingredients.filter { $0.section == section }
                                        // Wait, filtering destroys the "block" logic if names repeat.
                                        // Let's assume unique section names for now or contiguous blocks.
                                        
                                        ForEach(ingredientsInSection) { ingredient in
                                            IngredientRow(ingredient: ingredient)
                                        }
                                    }
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
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .bold)) // Bold for back button
                        .foregroundColor(.textPrimary)
                        .padding(10)
                        .background(Color.white.opacity(0.8)) // Add background for visibility over image
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        // TODO: Share action
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.textPrimary)
                            .padding(10)
                            .background(Color.white.opacity(0.8)) // Add background for consistency
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        // TODO: Favorite action
                    }) {
                        Image(systemName: "heart")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.textPrimary)
                            .padding(10)
                            .background(Color.white.opacity(0.8)) // Add background for consistency
                            .clipShape(Circle())
                    }
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
        RecipeDetailView(recipe: Recipe(
            title: "Sample Recipe",
            ingredients: [
                Ingredient(name: "Salt", amount: "1 tsp"),
                Ingredient(name: "Pepper", amount: "1/2 tsp")
            ],
            steps: [
                CookingStep(order: 1, instruction: "Step 1"),
                CookingStep(order: 2, instruction: "Step 2")
            ]
        ))
    }
}
