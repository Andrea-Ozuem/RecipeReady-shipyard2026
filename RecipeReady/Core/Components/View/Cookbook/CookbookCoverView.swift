//
//  CookbookCoverView.swift
//  RecipeReady
//
//  Displays the visual cover of a cookbook (Collage or Favorites style).
//

import SwiftUI

struct CookbookCoverView: View {
    let cookbook: Cookbook
    
    var body: some View {
        ZStack {
            // Background varies: Favorites uses softBeige, Collage uses White (gap color)
            if cookbook.isFavorites {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.softBeige)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            }
            
            if cookbook.isFavorites {
                // Favorites Style: Centered Heart
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.primaryOrange)
            } else {
                // Collage Style: 1 Top, 2 Bottom
                GeometryReader { geo in
                    let spacing: CGFloat = 5
                    let halfHeight = max(0, (geo.size.height - spacing) / 2)
                    let halfWidth = max(0, (geo.size.width - spacing) / 2)
                    
                    // Get first 3 added recipes with images
                    // User requested: "the first 3 means the first 3 that were added" -> Ascending sort
                    let recipesWithImages = cookbook.recipes
                        .filter { $0.imageURL != nil }
                        .sorted(by: { $0.createdAt < $1.createdAt }) // Oldest first
                        .prefix(3)
                    
                    let imagePaths = recipesWithImages.compactMap { $0.imageURL }
                    
                    VStack(spacing: spacing) {
                        // Top Half
                        Group {
                            if let path = imagePaths.first {
                                imageView(for: path, width: geo.size.width, height: halfHeight)
                            } else {
                                Rectangle().fill(Color.softBeige)
                            }
                        }
                        .frame(width: geo.size.width, height: halfHeight)
                        .clipped()
                        
                        // Bottom Half
                        HStack(spacing: spacing) {
                            // Bottom Left
                            Group {
                                if imagePaths.count > 1 {
                                    imageView(for: imagePaths[1], width: halfWidth, height: halfHeight)
                                } else {
                                    Rectangle().fill(Color.softBeige)
                                }
                            }
                            .frame(width: halfWidth, height: halfHeight)
                            .clipped()
                            
                            // Bottom Right
                            Group {
                                if imagePaths.count > 2 {
                                    imageView(for: imagePaths[2], width: halfWidth, height: halfHeight)
                                } else {
                                    Rectangle().fill(Color.softBeige)
                                }
                            }
                            .frame(width: halfWidth, height: halfHeight)
                            .clipped()
                        }
                        .frame(height: halfHeight)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .aspectRatio(0.8, contentMode: .fill) // Vertical Aspect Ratio
    }
    
    @ViewBuilder
    private func imageView(for path: String, width: CGFloat, height: CGFloat) -> some View {
        // Check if path is a URL (remote) or filename (local)
        // Simple heuristic: If it starts with http, it's remote.
        if path.hasPrefix("http") || path.hasPrefix("https") {
            if let url = URL(string: path) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: height)
                            .clipped()
                    } else {
                        Color.softBeige
                            .overlay(ProgressView())
                    }
                }
            } else {
                 Color.softBeige
            }
        } else {
            // Assume local file
            if let uiImage = loadLocalImage(named: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                // Fallback / Placeholder
                 Color.softBeige
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    private func loadLocalImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
