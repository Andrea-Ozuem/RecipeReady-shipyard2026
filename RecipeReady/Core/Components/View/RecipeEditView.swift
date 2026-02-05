//
//  RecipeEditView.swift
//  RecipeReady
//
//  Editable view for modifying recipe ingredients and steps.
//  Matches the visual style of RecipeDetailView.
//

import SwiftUI
import SwiftData

struct RecipeEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // We bind to the recipe object directly if we want live updates,
    // OR we use local state and save on "Save".
    // Given the previous implementation used local state to allow "Cancel",
    // we will stick to that pattern.
    
    let recipe: Recipe
    
    // State buffer for editing
    @State private var title: String
    @State private var ingredients: [Ingredient]
    @State private var steps: [CookingStep]
    
    // Metadata
    @State private var prepTime: Int?
    @State private var bakeTime: Int?
    @State private var restTime: Int?
    @State private var difficulty: String?
    @State private var servings: Int = 4
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _title = State(initialValue: recipe.title)
        _ingredients = State(initialValue: recipe.ingredients)
        _steps = State(initialValue: recipe.steps)
        _prepTime = State(initialValue: recipe.prepTime)
        _bakeTime = State(initialValue: recipe.bakingTime)
        _restTime = State(initialValue: recipe.restingTime)
        _difficulty = State(initialValue: recipe.difficulty)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Editable Header (Image + Title)
                    EditableHeaderView(title: $title)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Metadata (Difficulty & Times)
                        VStack(alignment: .leading, spacing: 24) {
                            // Difficulty (simplified to just text for now, could be picker)
                            HStack(alignment: .center, spacing: 4) {
                                Text("Difficulty:")
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                
                                // Simple difficulty rotation for now
                                Button(action: toggleDifficulty) {
                                    Text(difficulty ?? "Easy")
                                        .font(.bodyRegular)
                                        .foregroundColor(.primaryGreen)
                                        .underline()
                                }
                                Spacer()
                            }
                            
                            Divider().foregroundColor(Color.divider)
                            
                            // Editable Time Circles
                            HStack(spacing: 0) {
                                EditableTimeCircleView(title: "Preparation", minutes: $prepTime)
                                Spacer()
                                EditableTimeCircleView(title: "Baking", minutes: $bakeTime)
                                Spacer()
                                EditableTimeCircleView(title: "Resting", minutes: $restTime)
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 16)
                        
                        Divider().foregroundColor(Color.divider)
                        
                        // MARK: - Ingredients Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Ingredients")
                            
                            HStack {
                                Text("\(servings) Servings")
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                ServingsStepper(servings: $servings)
                            }
                            
                            VStack(spacing: 8) {
                                ForEach($ingredients) { $ingredient in
                                    EditableIngredientRow(
                                        ingredient: $ingredient,
                                        onDelete: {
                                            if let idx = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                                                ingredients.remove(at: idx)
                                            }
                                        }
                                    )
                                }
                                
                                Button(action: addIngredient) {
                                    Label("Add Ingredient", systemImage: "plus.circle")
                                        .font(.bodyBold)
                                        .foregroundColor(.primaryGreen)
                                        .padding(.vertical, 8)
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        Divider()
                        
                        // MARK: - Instructions Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Instructions")
                            
                            VStack(spacing: 12) {
                                ForEach(Array($steps.enumerated()), id: \.element.id) { index, $step in
                                    EditableInstructionRow(
                                        step: $step,
                                        index: index + 1,
                                        onDelete: {
                                            if let idx = steps.firstIndex(where: { $0.id == step.id }) {
                                                steps.remove(at: idx)
                                                reorderSteps()
                                            }
                                        }
                                    )
                                }
                                
                                Button(action: addStep) {
                                    Label("Add Step", systemImage: "plus.circle")
                                        .font(.bodyBold)
                                        .foregroundColor(.primaryGreen)
                                        .padding(.vertical, 8)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.top, 16)
                        
                        // Extra padding at bottom
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // Custom Floating Header (Cancel / Save)
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.3)) // Background for contrast
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button("Save") {
                    saveChanges()
                }
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.primaryGreen) // Green for primary action
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 8) // Adjust for safe area if needed, but standard padding usually clears it on dynamic island
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - Actions
    
    private func toggleDifficulty() {
        // Simple cycler
        let levels = ["Easy", "Medium", "Hard"]
        if let current = difficulty, let idx = levels.firstIndex(of: current) {
            difficulty = levels[(idx + 1) % levels.count]
        } else {
            difficulty = "Medium"
        }
    }
    
    private func addIngredient() {
        ingredients.append(Ingredient(name: "New Ingredient", amount: ""))
    }
    
    private func addStep() {
        let nextOrder = (steps.map(\.order).max() ?? 0) + 1
        steps.append(CookingStep(order: nextOrder, instruction: ""))
    }
    
    private func reorderSteps() {
        for (index, _) in steps.enumerated() {
            steps[index].order = index + 1
        }
    }
    
    private func saveChanges() {
        recipe.title = title
        recipe.ingredients = ingredients.filter { !$0.name.isEmpty }
        recipe.steps = steps.filter { !$0.instruction.isEmpty }
        
        recipe.prepTime = prepTime
        recipe.bakingTime = bakeTime
        recipe.restingTime = restTime
        recipe.difficulty = difficulty
        
        recipe.updatedAt = Date()
        
        // If recipe is not in context (e.g., newly extracted), insert it now.
        if recipe.modelContext == nil {
            // Query for favorites cookbook
            let descriptor = FetchDescriptor<Cookbook>(
                predicate: #Predicate { $0.isFavorites == true }
            )
            
            if let favoritesCookbook = try? modelContext.fetch(descriptor).first {
                // Add recipe to favorites
                favoritesCookbook.recipes.append(recipe)
            }
            
            modelContext.insert(recipe)
        }
        
        dismiss()
    }
}

#Preview {
    RecipeEditView(recipe: Recipe(
        title: "Sample Recipe",
        ingredients: [
            Ingredient(name: "Salt", amount: "1 tsp"),
            Ingredient(name: "Pepper", amount: "1/2 tsp")
        ],
        steps: [
            CookingStep(order: 1, instruction: "Step one is verify simple."),
            CookingStep(order: 2, instruction: "Step two is also quite straightforward.")
        ]
    ))
}
