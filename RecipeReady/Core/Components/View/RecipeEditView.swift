//
//  RecipeEditView.swift
//  RecipeReady
//
//  Editable view for modifying recipe ingredients and steps.
//

import SwiftUI
import SwiftData

struct RecipeEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let recipe: Recipe
    
    @State private var title: String
    @State private var ingredients: [Ingredient]
    @State private var steps: [CookingStep]
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _title = State(initialValue: recipe.title)
        _ingredients = State(initialValue: recipe.ingredients)
        _steps = State(initialValue: recipe.steps)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                ingredientsSection
                stepsSection
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.clear, for: .navigationBar) // Fix for white pills
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var titleSection: some View {
        Section("Title") {
            TextField("Recipe title", text: $title)
        }
    }
    
    private var ingredientsSection: some View {
        Section("Ingredients") {
            ForEach($ingredients) { $ingredient in
                HStack {
                    TextField("Ingredient", text: $ingredient.name)
                    TextField("Amount", text: Binding(
                        get: { ingredient.amount ?? "" },
                        set: { ingredient.amount = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(width: 100)
                    .foregroundStyle(.secondary)
                }
            }
            .onDelete(perform: deleteIngredient)
            .onMove(perform: moveIngredient)
            
            Button {
                addIngredient()
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle")
            }
        }
    }
    
    private var stepsSection: some View {
        Section("Steps") {
            ForEach($steps) { $step in
                HStack(alignment: .top) {
                    Text("\(step.order).")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                    
                    TextField("Instruction", text: $step.instruction, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .onDelete(perform: deleteStep)
            .onMove(perform: moveStep)
            
            Button {
                addStep()
            } label: {
                Label("Add Step", systemImage: "plus.circle")
            }
        }
    }
    
    // MARK: - Actions
    
    private func addIngredient() {
        ingredients.append(Ingredient(name: ""))
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    private func moveIngredient(from source: IndexSet, to destination: Int) {
        ingredients.move(fromOffsets: source, toOffset: destination)
    }
    
    private func addStep() {
        let nextOrder = (steps.map(\.order).max() ?? 0) + 1
        steps.append(CookingStep(order: nextOrder, instruction: ""))
    }
    
    private func deleteStep(at offsets: IndexSet) {
        steps.remove(atOffsets: offsets)
        reorderSteps()
    }
    
    private func moveStep(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
        reorderSteps()
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
        recipe.updatedAt = Date()
        
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
            CookingStep(order: 1, instruction: "Step one"),
            CookingStep(order: 2, instruction: "Step two")
        ]
    ))
}
