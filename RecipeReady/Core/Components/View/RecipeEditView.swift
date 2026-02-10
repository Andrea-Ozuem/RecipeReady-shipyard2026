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
    @Environment(ExtractionManager.self) private var extractionManager
    
    // We bind to the recipe object directly if we want live updates,
    // OR we use local state and save on "Save".
    // Given the previous implementation used local state to allow "Cancel",
    // we will stick to that pattern.
    
    let recipe: Recipe
    
    // State buffer for editing
    @State private var title: String
    @State private var sourceLink: String // Added sourceLink
    @State private var ingredients: [Ingredient]
    @State private var steps: [CookingStep]
    
    // Metadata
    @State private var prepTime: Int?
    @State private var bakeTime: Int?
    @State private var restTime: Int?
    @State private var difficulty: String?
    @State private var servings: Int = 1
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _title = State(initialValue: recipe.title)
        _sourceLink = State(initialValue: recipe.sourceLink ?? "") // Initialize sourceLink
        _ingredients = State(initialValue: recipe.ingredients)
        _steps = State(initialValue: recipe.steps)
        _prepTime = State(initialValue: recipe.prepTime)
        _bakeTime = State(initialValue: recipe.bakingTime)
        _restTime = State(initialValue: recipe.restingTime)
        _difficulty = State(initialValue: recipe.difficulty)
        _servings = State(initialValue: recipe.servings ?? 1)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Editable Header (Image + Title)
                    EditableHeaderView(title: $title, imageURL: recipe.imageURL)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Source Link Input
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            TextField("Source URL (e.g. from Instagram/TikTok)", text: $sourceLink)
                                .font(.bodyRegular)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
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
                                EditableTimeCircleView(title: "Cooking", minutes: $bakeTime)
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
                            
                            // Grouping Logic
                            let sectionKeys = ingredients.reduce(into: [String?]()) { keys, ingredient in
                                if keys.isEmpty {
                                    keys.append(ingredient.section)
                                } else if keys[keys.count - 1] != ingredient.section {
                                    keys.append(ingredient.section)
                                }
                            }
                            
                            VStack(spacing: 24) {
                                ForEach(Array(sectionKeys.enumerated()), id: \.offset) { index, sectionName in
                                    VStack(alignment: .leading, spacing: 8) {
                                        // Section Header
                                        HStack {
                                            TextField("Section Name (e.g. Sauce)", text: Binding(
                                                get: { sectionName ?? "" },
                                                set: { newName in
                                                    updateSectionName(oldName: sectionName, newName: newName)
                                                }
                                            ))
                                            .font(.headline)
                                            .foregroundColor(.primaryGreen)
                                            
                                            Spacer()
                                            
                                            // Delete Section Button (optional, maybe just delete all ingredients?)
                                        }
                                        
                                        // Ingredients in this section
                                        // We need indices to bind correctly
                                        let indices = ingredients.indices.filter { ingredients[$0].section == sectionName }
                                        
                                        ForEach(indices, id: \.self) { ingredientIndex in
                                            EditableIngredientRow(
                                                ingredient: $ingredients[ingredientIndex],
                                                onDelete: {
                                                    ingredients.remove(at: ingredientIndex)
                                                }
                                            )
                                        }
                                        
                                        // Add Ingredient to THIS section
                                        Button(action: { addIngredient(to: sectionName) }) {
                                            Label("Add Item to \(sectionName?.isEmpty == false ? sectionName! : "Main")", systemImage: "plus")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                                
                                // Add New Section Button
                                Button(action: addSection) {
                                    Label("Add New Section", systemImage: "folder.badge.plus")
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
                                ForEach(steps.indices, id: \.self) { index in
                                    EditableInstructionRow(
                                        step: $steps[index],
                                        index: index + 1,
                                        onDelete: {
                                            if steps.indices.contains(index) {
                                                steps.remove(at: index)
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
    
    private func updateSectionName(oldName: String?, newName: String?) {
        let finalName = (newName?.isEmpty ?? true) ? nil : newName
        // Update all ingredients in this matching block
        // Note: This replaces ALL ingredients with this section name, globally. 
        // If we supported non-contiguous sections with same name, this might be side-effecty, 
        // but for now it's desired behavior (renaming the Group).
        for i in ingredients.indices {
            if ingredients[i].section == oldName {
                ingredients[i].section = finalName
            }
        }
    }

    private func addIngredient(to section: String? = nil) {
        // Find insertion index: after the last item of this section
        if let lastIndex = ingredients.lastIndex(where: { $0.section == section }) {
            ingredients.insert(Ingredient(name: "", amount: "", section: section), at: lastIndex + 1)
        } else {
            // Append if section not found (or empty list)
            ingredients.append(Ingredient(name: "", amount: "", section: section))
        }
    }
    
    private func addSection() {
        // Add a new ingredient with a placeholder section
        // user can then rename it.
        ingredients.append(Ingredient(name: "", amount: "", section: "New Section"))
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
        recipe.sourceLink = sourceLink.isEmpty ? nil : sourceLink // Save sourceLink
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
            
            // Ensure the flag is set for the dynamic query in FavoritesCollectionCard
            recipe.isFavorite = true
            
            modelContext.insert(recipe)
        }
        
        // Explicit save to ensure persistence immediately
        try? modelContext.save()
        
        // If we are in extraction flow, notify manager we are done
        extractionManager.dismiss()
        print("💾 RecipeEditView: Saved recipe \(recipe.title), dismissing...")
        
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
