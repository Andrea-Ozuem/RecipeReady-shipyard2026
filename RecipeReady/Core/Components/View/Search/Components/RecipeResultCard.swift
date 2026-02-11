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
                // Recipe Image
                if let imageURLString = imageURL,
                   !imageURLString.isEmpty {
                    if imageURLString.hasPrefix("http"),
                       let url = URL(string: imageURLString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                recipePlaceholder
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            case .failure:
                                recipePlaceholder
                            @unknown default:
                                recipePlaceholder
                            }
                        }
                        .aspectRatio(0.8, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .clipped()
                    } else {
                        // Local file (Documents dir) or asset catalog fallback
                        if let uiImage = loadLocalImage(named: imageURLString) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 170)
                                .aspectRatio(0.8, contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .clipped()
                        } else {
                            Image(imageURLString) // Asset catalog (e.g. "recipe1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 170)
                                .aspectRatio(0.8, contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .clipped()
                        }
                    }
                } else {
                    recipePlaceholder
                }
                
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
    
    private var recipePlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .aspectRatio(0.8, contentMode: .fill)
            .overlay(
                Image(systemName: "fork.knife")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .clipped()
    }
    
    private func loadLocalImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

#Preview {
    RecipeResultCard(recipeTitle: "Homemade Lasagna", time: "70 min.", imageURL: nil)
}
