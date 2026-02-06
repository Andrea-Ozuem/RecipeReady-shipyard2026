//
//  RecipeResultCard.swift
//  RecipeReady
//
//  A card view displaying a recipe result with image, title, and time.
//

import SwiftUI

struct RecipeResultCard: View {
    let recipeTitle: String
    let time: String
    let imageURL: String? // Placeholder logic for now
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with Overlays
            ZStack(alignment: .topLeading) {
                // Placeholder Image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(0.8, contentMode: .fill) // Portrait (Taller)
                    .overlay(
                         Image(systemName: "fork.knife")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .clipped()
                
                // Badges Left Top
                HStack(spacing: 8) {
                    Text(time)
                        .font(.captionMeta)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.softBeige)
                        .cornerRadius(20)
                }
                .padding(12)
                
                // Like Badge Bottom Right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .font(.system(size: 14))
                                .foregroundColor(.textPrimary)
                            Text("3.4K") // Mock data
                                .font(.captionMeta)
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                }
                .padding(12)
            }
            .frame(width: 170) // Constrain width, let height grow by aspect ratio (~242)
            
            // Info Content
            VStack(alignment: .leading, spacing: 4) {
                Text(recipeTitle)
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Author Mock
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                    
                    Text("Hanna Reder")
                        .font(.caption)
                        .foregroundColor(.primaryOrange)
                }
            }
        }
        .frame(width: 170)
    }
}

#Preview {
    RecipeResultCard(recipeTitle: "Homemade Lasagna", time: "70 min.", imageURL: nil)
}
