//
//  ShoppingListView.swift
//  RecipeReady
//
//  Created for Shopping List implementation.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    List(viewModel.ingredients, id: \.self) { ingredient in
                        Text(ingredient)
                            .font(.bodyRegular)
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                // Temporary button to toggle state for testing
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation {
                            viewModel.toggleMockData()
                        }
                    }) {
                        Image(systemName: "flask") // Science flask for "Testing"
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration
            // Using a system image as a placeholder for now as discussed
            Image(systemName: "cart.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.primaryOrange.opacity(0.8))
                .padding(.bottom, 16)
            
            VStack(spacing: 12) {
                Text("You don't have recipes on your shopping list yet.")
                    .font(.heading1)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("When you add ingredients to your shopping list, you'll see them here! Happy shopping!")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer() // Push content slightly up
        }
        .padding()
    }
}

#Preview {
    ShoppingListView()
}
