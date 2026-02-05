import Foundation

// MARK: - Mocks for SwiftUI types to run in CLI
struct Color {
    static let textPrimary = "Color.textPrimary"
    static let textSecondary = "Color.textSecondary"
    static let primaryGreen = "Color.primaryGreen"
    static let clear = "Color.clear"
}

// MARK: - Models (Copied from Source)
struct ShoppingListIngredient: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let quantity: String
    var isChecked: Bool = false
    
    init(id: UUID = UUID(), name: String, quantity: String, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
    }
}

struct ShoppingListRecipe: Identifiable {
    let id = UUID()
    let title: String
    let imageURL: String?
    let totalItems: Int
    let missingItems: Int
    
    // Expanded State Props
    var isExpanded: Bool = false
    var servings: Int = 2
    var ingredients: [ShoppingListIngredient] = []
}

// MARK: - ViewModel Logic (Simplified for CLI)
class ShoppingListViewModel {
    var recipes: [ShoppingListRecipe] = []
    
    var isEmpty: Bool {
        recipes.isEmpty
    }
    
    // Helper to ensure unique IDs
    private func makeIngredient(name: String, quantity: String) -> ShoppingListIngredient {
        let ing = ShoppingListIngredient(id: UUID(), name: name, quantity: quantity)
        // print("Created Ingredient: \(name) - ID: \(ing.id)")
        return ing
    }

    func toggleMockData() {
        if isEmpty {
            recipes = [
                ShoppingListRecipe(
                    title: "Lamb's lettuce salad with crispy potatoes",
                    imageURL: nil,
                    totalItems: 14,
                    missingItems: 14,
                    ingredients: [
                        makeIngredient(name: "lamb's lettuce", quantity: "200 g"),
                        makeIngredient(name: "waxy potatoes", quantity: "300 g"),
                        makeIngredient(name: "brown mushrooms", quantity: "200 g"),
                        makeIngredient(name: "shallot", quantity: "1"),
                        makeIngredient(name: "chives", quantity: "10 g")
                    ]
                )
            ]
        }
    }
    
    func toggleIngredient(recipeID: UUID, ingredientID: UUID) {
        print("\n--- ACTION: Toggling Ingredient ---")
        // print("Attempting to toggle ingredient: \(ingredientID) in recipe: \(recipeID)")
        if let recipeIndex = recipes.firstIndex(where: { $0.id == recipeID }) {
            if let ingredientIndex = recipes[recipeIndex].ingredients.firstIndex(where: { $0.id == ingredientID }) {
                print("Target Found: \(recipes[recipeIndex].ingredients[ingredientIndex].name)")
                recipes[recipeIndex].ingredients[ingredientIndex].isChecked.toggle()
            } else {
                print("Ingredient NOT FOUND with ID: \(ingredientID)")
            }
        } else {
             print("Recipe NOT FOUND with ID: \(recipeID)")
        }
    }
}

// MARK: - Verification Script
let vm = ShoppingListViewModel()
vm.toggleMockData()

let recipe = vm.recipes[0]
print("Recipe Created: \(recipe.title)")
print("Ingredients Count: \(recipe.ingredients.count)")

// Check for ID Uniqueness
print("\n--- CHECK: ID Uniqueness ---")
let ids = recipe.ingredients.map { $0.id }
let uniqueIds = Set(ids)
if ids.count == uniqueIds.count {
    print("✅ All \(ids.count) ingredients have unique IDs.")
} else {
    print("❌ DUPLICATE IDs FOUND! Unique count: \(uniqueIds.count)")
}

// Test Selection
let firstIngredient = recipe.ingredients[0]
let secondIngredient = recipe.ingredients[1]

print("\nInitial State:")
print("- \(firstIngredient.name): \(firstIngredient.isChecked)")
print("- \(secondIngredient.name): \(secondIngredient.isChecked)")

// Toggle First Ingredient
vm.toggleIngredient(recipeID: recipe.id, ingredientID: firstIngredient.id)

print("\nPost-Toggle State:")
let updatedFirst = vm.recipes[0].ingredients[0]
let updatedSecond = vm.recipes[0].ingredients[1]

print("- \(updatedFirst.name): \(updatedFirst.isChecked)")
print("- \(updatedSecond.name): \(updatedSecond.isChecked)")

if updatedFirst.isChecked == true && updatedSecond.isChecked == false {
    print("\n✅ SUCCESS: Only the target ingredient was toggled.")
} else {
    print("\n❌ FAILURE: Selection state is incorrect.")
}
