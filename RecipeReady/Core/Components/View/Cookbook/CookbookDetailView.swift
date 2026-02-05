//
//  CookbookDetailView.swift
//  RecipeReady
//
//  Displays the recipes within a specific cookbook.
//

import SwiftUI
import SwiftData

struct CookbookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let cookbook: Cookbook
    
    @State private var isShowingEditSheet = false
    
    // Grid Setup
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    // Show recipes in this cookbook
                    ForEach(cookbook.recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCardView(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color.screenBackground)
            .navigationBarBackButtonHidden(true) // Custom back button
            .toolbarBackground(Color.clear, for: .navigationBar) // User suggested fix for white pills
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(cookbook.title)
                        .font(.heading1)
                        .foregroundColor(.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.textPrimary)
                        }
                        
                        Button(action: {
                            isShowingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditCookbookSheet(cookbook: cookbook)
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
            }
    }
}

#Preview {
    CookbookDetailView(cookbook: Cookbook(title: "Salad", isFavorites: false))
        .modelContainer(for: [Recipe.self, Cookbook.self], inMemory: true)
}
