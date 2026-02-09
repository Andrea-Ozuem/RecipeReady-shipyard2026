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
                if let imageURLString = recipe.imageURL {
                    if imageURLString.hasPrefix("http") || imageURLString.hasPrefix("https"), let url = URL(string: imageURLString) {
                        AsyncImage(url: url) { phase in
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
                    } else if let uiImage = loadLocalImage(named: imageURLString) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
                
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
                    .font(.iconRegular)
                    .foregroundColor(.textSecondary)
                    .rotationEffect(.degrees(90)) // Vertical ellipsis
                    .frame(width: 44, height: 44) // Explicit touch target
                    .contentShape(Rectangle()) // Ensure entire frame is tappable
            }
            .buttonStyle(.borderless) // Prevent row selection interference
            .padding(.top, -12) // Align adjustments
        }
        .padding(.vertical, 12)
        .background(Color.white) // Ensure tap area
    }
    
    private func loadLocalImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingListRecipe.self, ShoppingListItem.self, configurations: config)
    let recipe = ShoppingListRecipe(title: "Test Recipe", imageURL: nil)
    
    return ShoppingListRecipeRow(recipe: recipe)
        .padding()
}
