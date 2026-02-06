//
//  EditableHeaderView.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct EditableHeaderView: View {
    @Binding var title: String
    let imageURL: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Hero Image
            // MARK: - Hero Image
            if let imageURLString = imageURL {
                // Check if it's a remote URL
                if imageURLString.hasPrefix("http") || imageURLString.hasPrefix("https"), let url = URL(string: imageURLString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            placeholderImage
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 300)
                    .clipped()
                } else {
                    // Assume local file path
                    if let uiImage = loadLocalImage(named: imageURLString) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                    } else {
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Title Editing
                TextField("Recipe Title", text: $title, axis: .vertical)
                    .font(.heading1.bold())
                    .foregroundColor(.textPrimary)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    Text("Add Photo")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            )
            .frame(height: 300)
            .clipped()
    }
    
    private func loadLocalImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
