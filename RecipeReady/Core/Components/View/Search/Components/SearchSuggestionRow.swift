//
//  SearchSuggestionRow.swift
//  RecipeReady
//
//  A row displaying an ingredient suggestion with a favorite toggle.
//

import SwiftUI

struct SearchSuggestionRow: View {
    let name: String
    let isFavorite: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(name)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFavorite ? .primaryBlue : .textPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white) // Ensure tappable area
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button highlight
    }
}

#Preview {
    VStack {
        SearchSuggestionRow(
            name: "Alpine cheese",
            isFavorite: true,
            onSelect: {},
            onToggleFavorite: {}
        )
        SearchSuggestionRow(
            name: "blue cheese",
            isFavorite: false,
            onSelect: {},
            onToggleFavorite: {}
        )
    }
}
