//
//  CookbookView.swift
//  RecipeReady
//
//  Displays the user's saved recipe collections.
//

import SwiftUI
import SwiftData

struct CookbookView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Cookbook> { $0.isFavorites == true }) var favoriteCookbooks: [Cookbook] // Should be 0 or 1
    @Query(filter: #Predicate<Cookbook> { !$0.isFavorites }, sort: \Cookbook.createdAt, order: .forward) var cookbooks: [Cookbook]
    
    // Grid Setup: 2 columns with spacing
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var isShowingAddCookbook = false
    @State private var errorMessage: String?
    @State private var showError = false

    // Look for recipes that are favorite but maybe not linked?
    // Actually we can't easily query that inside onAppear without a macro or fetch.
    // We will do a manual fetch in onAppear.
    
    public init() {}
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header
                HStack {
                    Text("Saved")
                        .font(.display)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingAddCookbook = true
                    }) {
                        Image(systemName: "plus")
                            .font(.iconRegular)
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // MARK: - Grid Content
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        // 1. "Favorites" Cookbook (Real Persisted)
                        if let favorites = favoriteCookbooks.first {
                            NavigationLink(destination: CookbookDetailView(cookbook: favorites)) {
                                CollectionCard(cookbook: favorites)
                            }
                        }
                        
                        // 2. User Created Cookbooks
                        ForEach(cookbooks) { cookbook in
                             NavigationLink(destination: CookbookDetailView(cookbook: cookbook)) {
                                 CollectionCard(cookbook: cookbook)
                             }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.screenBackground)
            .navigationBarHidden(true)
            .onAppear {
                ensureFavoritesSynced()
            }
            .sheet(isPresented: $isShowingAddCookbook) {
                AddCookbookSheet(onSave: { newTitle in
                    do {
                        let newCookbook = Cookbook(name: newTitle)
                        modelContext.insert(newCookbook)
                        try modelContext.save()
                    } catch {
                        errorMessage = "Failed to create cookbook: \(error.localizedDescription)"
                        showError = true
                    }
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }
    
    private func ensureFavoritesSynced() {
        // 1. Ensure cookbook exists
        let favorites: Cookbook
        if let existing = favoriteCookbooks.first {
            favorites = existing
        } else {
            favorites = Cookbook(name: "My favourite recipes", coverColor: "#FF6B35", isFavorites: true)
            modelContext.insert(favorites)
            // Save needed to get hash?
        }
        
        // 2. Sync recipes
        // Fetch all recipes where isFavorite == true
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.isFavorite == true }
        )
        if let favRecipes = try? modelContext.fetch(descriptor) {
            var changed = false
            for recipe in favRecipes {
                if !favorites.recipes.contains(where: { $0.id == recipe.id }) {
                    favorites.recipes.append(recipe)
                    changed = true
                }
            }
            
            if changed {
               try? modelContext.save()
            }
        }
    }
}

// MARK: - Subviews

struct CollectionCard: View {
    let cookbook: Cookbook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Card Visual
            CookbookCoverView(cookbook: cookbook)
            
            // Meta Text
            VStack(alignment: .leading, spacing: 4) {
                Text(cookbook.name)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text("\(cookbook.recipes.count) items")
                    .font(.captionMeta)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// Removed FavoritesCollectionCard as it is no longer used

// MARK: - Sheets

struct AddCookbookSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (String) -> Void
    
    @State private var title: String = ""
    
    // Focus state for the input field to potentially drive border color
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                // Title Label
                Text("Title")
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)
                
                // Input Field
                TextField("Title", text: $title)
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(12)
                
                Spacer()
                
                // Full-width Save Button at bottom
                Button(action: {
                    if !title.isEmpty {
                        onSave(title)
                        dismiss()
                    }
                }) {
                    Text("Save cookbook")
                        .font(.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryGreen)
                        .cornerRadius(25)
                }
            }
            .padding(20)
            .navigationTitle("Create a cookbook")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CookbookView()
}
