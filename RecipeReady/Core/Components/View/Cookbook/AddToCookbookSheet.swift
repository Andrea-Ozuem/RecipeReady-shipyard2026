//
//  AddToCookbookSheet.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI
import SwiftData

struct AddToCookbookSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    let moveFromCookbook: Cookbook?
    
    // Sort logic: Favorites first, then alphabetical or by date
    @Query(sort: [
        SortDescriptor<Cookbook>(\.isFavorites, order: .reverse),
        SortDescriptor<Cookbook>(\.name, order: .forward)
    ])
    private var allCookbooks: [Cookbook]
    
    // Local state to track selections before saving?
    // Or save immediately? The design "Save" button implies deferred saving.
    // We will track selected cookbook IDs.
    @State private var selectedCookbookIDs: Set<PersistentIdentifier> = []
    
    @State private var showNewCookbookAlert = false
    @State private var newCookbookName = ""
    
    init(recipe: Recipe, moveFromCookbook: Cookbook? = nil) {
        self.recipe = recipe
        self.moveFromCookbook = moveFromCookbook
        // _allCookbooks is initialized by the property wrapper default value
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Create New Cookbook Option
                    Button(action: {
                        newCookbookName = ""
                        showNewCookbookAlert = true
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    // Use stroke for border-box feel as per design
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 64, height: 64)
                                    
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.textPrimary)
                            }
                            
                            Text("Save in new cookbook")
                                .font(.bodyBold)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)

                    // List existing cookbooks
                    ForEach(allCookbooks) { cookbook in
                        cookbookRow(for: cookbook)
                    }
                }
                .padding(.bottom, 100) // Space for fixed button
            }
            
            Spacer()
            
            // Save Button
            Button(action: {
                saveChanges()
                dismiss()
            }) {
                Text("Save")
                    .font(.bodyBold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primaryGreen)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Bottom safe area approximation or standard padding
        }
        .background(Color.white)
        .onAppear {
            checkAndCreateFavorites()
            initializeSelections()
        }
        .alert("New Cookbook", isPresented: $showNewCookbookAlert) {
            TextField("Name", text: $newCookbookName)
            Button("Cancel", role: .cancel) { }
            Button("Create") {
                createNewCookbook()
            }
        }
    }
    
    private func checkAndCreateFavorites() {
        // optimistically check if we have it in the query result or fetch specifically
        // usage of allCookbooks here is strictly safe only if Query is populated, 
        // but Query might be empty initially? No, it should satisfy immediately.
        if !allCookbooks.contains(where: { $0.isFavorites }) {
            let favorites = Cookbook(name: "My favourite recipes", coverColor: "#FF6B35", isFavorites: true)
            modelContext.insert(favorites)
            // No need to save explicitly, autosave or next cycle will handle it, 
            // but for immediate UI selection logic we might want to know about it.
        }
    }
    
    private func cookbookRow(for cookbook: Cookbook) -> some View {
        Button(action: {
            toggleSelection(for: cookbook)
        }) {
            HStack(spacing: 16) {
                // Icon / Leading view
                if cookbook.isFavorites {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.inputBackgroundLight)
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primaryBlue)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryBlue) // User requested primary blue fill
                            .frame(width: 64, height: 64)
                            
                        Image(systemName: "book.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.inputBackground)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(cookbook.name)
                        .font(.bodyBold)
                        .foregroundColor(.textPrimary)
                    
                    Text("\(cookbook.recipes.count) recipes")
                        .font(.bodyRegular) // using standard size
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Checkbox
                let isSelected = selectedCookbookIDs.contains(cookbook.persistentModelID)
                
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .primaryGreen : .gray.opacity(0.5))
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Logic
    
    private func initializeSelections() {
        // Find which cookbooks already contain this recipe
        // Since many-to-many isn't always direct in SwiftData (sometimes array of IDs), 
        // we check if cookbook.recipes contains this recipe.
        for cookbook in allCookbooks {
            if cookbook.recipes.contains(where: { $0.id == recipe.id }) {
                // If we are moving FROM this cookbook, we do NOT select it initially.
                // This means if the user saves without re-checking it, it will be removed.
                if let from = moveFromCookbook, from.persistentModelID == cookbook.persistentModelID {
                    continue
                }
                selectedCookbookIDs.insert(cookbook.persistentModelID)
            }
        }
    }
    
    private func toggleSelection(for cookbook: Cookbook) {
        if selectedCookbookIDs.contains(cookbook.persistentModelID) {
            selectedCookbookIDs.remove(cookbook.persistentModelID)
        } else {
            selectedCookbookIDs.insert(cookbook.persistentModelID)
        }
    }
    
    private func createNewCookbook() {
        guard !newCookbookName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newCookbook = Cookbook(name: newCookbookName)
        modelContext.insert(newCookbook)
        
        // Auto-select the new cookbook
        // We save context to generate ID
        try? modelContext.save() 
        selectedCookbookIDs.insert(newCookbook.persistentModelID)
    }
    
    private func saveChanges() {
        for cookbook in allCookbooks {
            let isSelected = selectedCookbookIDs.contains(cookbook.persistentModelID)
            let inputsRecipe = cookbook.recipes.contains(where: { $0.id == recipe.id })
            
            if isSelected && !inputsRecipe {
                // Add
                cookbook.recipes.append(recipe)
                // specific logic for Favorites sync
                if cookbook.isFavorites {
                    recipe.isFavorite = true
                }
            } else if !isSelected && inputsRecipe {
                // Remove
                if let index = cookbook.recipes.firstIndex(where: { $0.id == recipe.id }) {
                    cookbook.recipes.remove(at: index)
                }
                // specific logic for Favorites sync
                if cookbook.isFavorites {
                    recipe.isFavorite = false
                }
            }
        }
        
        try? modelContext.save()
    }
}

#Preview {
   // Preview setup would require ModelContainer
   Text("AddToCookbookSheet Preview")
}
