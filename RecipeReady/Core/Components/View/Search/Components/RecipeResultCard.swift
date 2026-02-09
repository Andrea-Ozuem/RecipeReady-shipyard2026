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
                            .font(.system(size: 40, weight: .light))
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
            }
            .frame(width: 170) // Constrain width, let height grow by aspect ratio (~242)
            
            // Info Content
            VStack(alignment: .leading, spacing: 4) {
                Text(recipeTitle)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: 170)
    }
}

#Preview {
    RecipeResultCard(recipeTitle: "Homemade Lasagna", time: "70 min.", imageURL: nil)
}
