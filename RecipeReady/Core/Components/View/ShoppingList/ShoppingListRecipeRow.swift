//
//  ShoppingListRecipeRow.swift
//  RecipeReady
//
//  Created for Grocery List implementation.
//

import SwiftUI
import SwiftData

struct ShoppingListRecipeRow: View {
    let recipe: ShoppingListRecipe
    var onToggleExpand: () -> Void = {}
    var onMoreTap: () -> Void = {}
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Main clickable content area
            HStack(alignment: .top, spacing: 16) {
                // Thumbnail
                AsyncImage(url: URL(string: recipe.imageURL ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.bodyRegular)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(2)
                    
                    Text("\(recipe.missingItems) out of \(recipe.totalItems) items missing")
                        .font(.captionMeta)
                        .foregroundStyle(Color.textPrimary)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggleExpand()
            }
            
            // More Options
            Button(action: onMoreTap) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16)) // Small icon
                    .foregroundColor(.textSecondary)
                    .rotationEffect(.degrees(90)) // Vertical ellipsis
                    .padding(8) // Increase hit area
            }
            .padding(.top, -4) // Align adjustments
        }
        .padding(.vertical, 12)
        .background(Color.white) // Ensure tap area
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingListRecipe.self, ShoppingListItem.self, configurations: config)
    let recipe = ShoppingListRecipe(title: "Test Recipe", imageURL: nil)
    
    return ShoppingListRecipeRow(recipe: recipe)
        .padding()
}
