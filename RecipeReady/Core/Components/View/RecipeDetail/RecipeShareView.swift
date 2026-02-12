//
//  RecipeShareView.swift
//  RecipeReady
//
//  Created by RecipeReady Team.
//
//  A view designed specifically for exporting as a PDF.
//

import SwiftUI

struct RecipeShareView: View {
    let recipe: Recipe
    
    // Standard PDF width (A4 is ~612pts width)
    private let exportWidth: CGFloat = 612
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Hero Image
            if let imageURLString = recipe.imageURL {
                 if imageURLString.hasPrefix("http"), let url = URL(string: imageURLString) {
                     AsyncImage(url: url) { phase in
                         if let image = phase.image {
                             image
                                 .resizable()
                                 .scaledToFill()
                         } else {
                             Rectangle()
                                 .fill(Color.gray.opacity(0.3))
                                 .overlay(Image(systemName: "fork.knife").foregroundColor(.white))
                         }
                     }
                     .frame(width: exportWidth, height: 400) // Taller suited for PDF
                     .clipped()
                 } else if let uiImage = loadLocalImage(named: imageURLString) {
                     Image(uiImage: uiImage)
                         .resizable()
                         .scaledToFill()
                         .frame(width: exportWidth, height: 400)
                         .clipped()
                 } else {
                     placeholderImage
                 }
            } else {
                placeholderImage
            }
            
            // MARK: - Content
            VStack(alignment: .leading, spacing: 24) {
                // Title
                Text(recipe.title)
                    .font(.heading1) // Design System
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                    
                // Metadata
                HStack(spacing: 24) {
                    if let time = recipe.cookingTime ?? recipe.prepTime {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                            Text("\(time) min")
                        }
                    }
                    
                    if let servings = recipe.servings {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2")
                            Text("\(servings) servings")
                        }
                    }
                    
                    if let difficulty = recipe.difficulty {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.bar")
                            Text(difficulty)
                        }
                    }
                }
                .font(.bodyBold)
                .foregroundColor(.textSecondary)
                
                Divider()
                    .background(Color.divider)
                
                // Ingredients (Full List)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredients")
                        .font(.heading2) // Slightly smaller than title
                        .foregroundColor(.textPrimary)
                    
                    ForEach(recipe.ingredients) { ingredient in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.primaryGreen)
                                .padding(.top, 8)
                            
                            Text(ingredient.name)
                                .font(.bodyRegular)
                                .foregroundColor(.textPrimary)
                            +
                            Text(ingredient.amount.map { " - \($0)" } ?? "")
                                .font(.bodyRegular)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                Divider()
                    .background(Color.divider)
                
                // Instructions (Full List)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.heading2)
                        .foregroundColor(.textPrimary)
                    
                    ForEach(recipe.steps.sorted { $0.order < $1.order }) { step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(step.order).")
                                .font(.bodyBold) // Number bold
                                .foregroundColor(.primaryGreen)
                                .frame(width: 24, alignment: .leading)
                            
                            Text(step.instruction)
                                .font(.bodyRegular)
                                .foregroundColor(.textPrimary)
                                .lineLimit(nil) // Ensure full text
                        }
                        .padding(.bottom, 8)
                    }
                }
                
                Spacer()
                
                // MARK: - Footer / Branding
                Divider()
                
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.title2)
                        .foregroundColor(.primaryGreen)
                    
                    Text("RecipeReady")
                        .font(.bodyBold)
                        .foregroundColor(.primaryGreen)
                    
                    Spacer()
                    
                    Text("recipeready.app")
                        .font(.captionMeta)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 12)
            }
            .padding(40) // Generous padding for PDF
            .background(Color.white)
        }
        .frame(width: exportWidth) // No height limit, let it grow
        .background(Color.white)
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.primaryGreen.opacity(0.1))
            .frame(width: exportWidth, height: 400)
            .overlay(
                Image(systemName: "fork.knife")
                    .font(.system(size: 80))
                    .foregroundColor(.primaryGreen.opacity(0.5))
            )
    }
    
    private func loadLocalImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

#Preview {
    RecipeShareView(recipe: SampleData.featured)
}
