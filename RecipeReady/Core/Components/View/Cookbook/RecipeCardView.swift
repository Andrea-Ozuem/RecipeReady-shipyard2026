//
//  RecipeCardView.swift
//  RecipeReady
//
//  Premium grid item for displaying a recipe.
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    let onMove: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Image & Badges
            ZStack(alignment: .topLeading) {
                // Async Image
                if let imageURLString = recipe.imageURL {
                    if imageURLString.hasPrefix("http") || imageURLString.hasPrefix("https"), let url = URL(string: imageURLString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else if let uiImage = loadLocalImage(named: imageURLString) {
                         Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        // Placeholder for failed local load
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .frame(height: 200) // Fixed height for masonry-like grid feeling
            
            // MARK: - Footer Info
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(recipe.title)
                        .font(.bodyRegular)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // More Action
                Menu {
                    Button(action: onMove) {
                        Label("Move", systemImage: "folder")
                    }
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.textSecondary)
                        .padding(8)
                }
            }
        }
    }
    
    private func loadLocalImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

#Preview {
    RecipeCardView(
        recipe: Recipe(
            title: "Sample Recipe",
            ingredients: [Ingredient(name: "Test", amount: "1")],
            steps: [CookingStep(order: 1, instruction: "Test")]
        ),
        onMove: {},
        onDelete: {}
    )
        .padding()
}
