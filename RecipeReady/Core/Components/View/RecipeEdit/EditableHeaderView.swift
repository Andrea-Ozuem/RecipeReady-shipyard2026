//
//  EditableHeaderView.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct EditableHeaderView: View {
    @Binding var title: String
    // In current implementation, we just have a placeholder for image as in RecipeDetailView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Hero Image Placeholder
            // Tapping this could trigger image picker in future
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
            
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Title Editing
                TextField("Recipe Title", text: $title, axis: .vertical)
                    .font(.largeTitle.bold())
                    .foregroundColor(.textPrimary)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
            }
        }
    }
}
