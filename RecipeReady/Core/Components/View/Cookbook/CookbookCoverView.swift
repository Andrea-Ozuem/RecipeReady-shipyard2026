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
                    
                    // Get first 3 recipes with images
                    let recipesWithImages = cookbook.recipes
                        .filter { $0.imageURL != nil }
                        .sorted(by: { $0.createdAt > $1.createdAt })
                        .prefix(3)
                    
                    let imageUrls = recipesWithImages.compactMap { $0.imageURL }
                    
                    VStack(spacing: spacing) {
                        // Top Half
                        Group {
                            if let urlString = imageUrls.first, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: halfHeight)
                                            .clipped()
                                    } else {
                                        Color.softBeige
                                    }
                                }
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
                                if imageUrls.count > 1, let url = URL(string: imageUrls[1]) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: halfWidth, height: halfHeight)
                                                .clipped()
                                        } else {
                                            Color.softBeige
                                        }
                                    }
                                } else {
                                    Rectangle().fill(Color.softBeige)
                                }
                            }
                            .frame(width: halfWidth, height: halfHeight)
                            .clipped()
                            
                            // Bottom Right
                            Group {
                                if imageUrls.count > 2, let url = URL(string: imageUrls[2]) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: halfWidth, height: halfHeight)
                                                .clipped()
                                        } else {
                                            Color.softBeige
                                        }
                                    }
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
}
