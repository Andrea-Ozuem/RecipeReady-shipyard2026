//
//  RecipeCard.swift
//  RecipeReady
//
//  Standard recipe card for Home screen horizontal lists.
//

import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            ZStack {
                if let imageURLString = recipe.imageURL {
                     if imageURLString.hasPrefix("http") || imageURLString.hasPrefix("https"), let url = URL(string: imageURLString) {
                         AsyncImage(url: url) { phase in
                             switch phase {
                             case .empty:
                                 Rectangle().fill(Color.gray.opacity(0.1))
                             case .success(let image):
                                 image.resizable().aspectRatio(contentMode: .fill)
                             case .failure:
                                 Rectangle().fill(Color.gray.opacity(0.1))
                             @unknown default:
                                 EmptyView()
                             }
                         }
                     } else {
                         // Local or fallback
                         Image(imageURLString) // Attempt to load from assets/local
                             .resizable()
                             .aspectRatio(contentMode: .fill)
                     }
                } else {
                    Rectangle().fill(Color.gray.opacity(0.1))
                }
            }
            .frame(width: 160, height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Meta
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: 160, alignment: .leading)
                
                HStack(spacing: 4) {
                    if let author = recipe.author {
                        // Avatar placeholder (circle) or text
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                            .overlay(Text(author.prefix(1)).font(.caption).foregroundColor(.white))
                        
                        Text(author)
                            .font(.captionMeta)
                            .foregroundColor(.textSecondary)
                    } else if let time = recipe.cookingTime {
                         Text("\(time) min")
                            .font(.captionMeta)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
    }
}

#Preview {
    RecipeCard(recipe: Recipe(
        title: "Aperol spritz tiramisu",
        author: "Marco Hartz",
        ingredients: [],
        steps: []
    ))
}
