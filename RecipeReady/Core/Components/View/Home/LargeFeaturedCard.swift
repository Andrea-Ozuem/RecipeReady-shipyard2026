//
//  LargeFeaturedCard.swift
//  RecipeReady
//
//  Hero component for Home screen.
//  "Oven Fresh and Cozy"
//

import SwiftUI

struct LargeFeaturedCard: View {
    let recipe: Recipe
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Full Height Image
            GeometryReader { geometry in
                if let imageURLString = recipe.imageURL {
                     if imageURLString.hasPrefix("http") || imageURLString.hasPrefix("https"), let url = URL(string: imageURLString) {
                         AsyncImage(url: url) { phase in
                             switch phase {
                             case .success(let image):
                                 image
                                     .resizable()
                                     .aspectRatio(contentMode: .fill)
                                     .frame(width: geometry.size.width, height: geometry.size.height)
                                     .clipped()
                             default:
                                 Rectangle().fill(Color.gray.opacity(0.1))
                             }
                         }
                     } else {
                         // Local file (Documents dir) or asset catalog fallback
                         if let uiImage = loadLocalImage(named: imageURLString) {
                             Image(uiImage: uiImage)
                                 .resizable()
                                 .aspectRatio(contentMode: .fill)
                                 .frame(width: geometry.size.width, height: geometry.size.height)
                                 .clipped()
                         } else {
                             Image(imageURLString) // Asset catalog
                                 .resizable()
                                 .aspectRatio(contentMode: .fill)
                                 .frame(width: geometry.size.width, height: geometry.size.height)
                                 .clipped()
                         }
                     }
                } else {
                     Rectangle().fill(Color.gray.opacity(0.1))
                }
            }
            
            // 2. Content Card (Floating Overlay)
            VStack(alignment: .leading, spacing: 12) {
                Text("Oven Fresh and Cozy")
                    .font(.captionMeta)
                    .foregroundColor(.textSecondary)
                
                Text(recipe.title)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                HStack {
                    if let author = recipe.author {
                        Text(author)
                            .font(.captionMeta)
                            .foregroundColor(.primaryBlue)
                    }
                    
                    Spacer()
                    
                }
            }
            .padding(24)
            .background(Color.softBeige)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .offset(y: 80) // Push card down to hang off the image
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .padding(.bottom, 80) // Add space for the hanging card so it doesn't overlap next section
    }
    
    private func loadLocalImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

#Preview {
    LargeFeaturedCard(recipe: Recipe(
        title: "Casseroles are the Best Kick-off for Autumn",
        author: "Qianyuhe",
        isFeatured: true,
        imageURL: "sample_casserole"
    ))
}
