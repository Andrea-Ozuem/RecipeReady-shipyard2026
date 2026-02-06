//
//  IngredientTag.swift
//  RecipeReady
//
//  A reusable view that displays an ingredient as a tappable tag/chip.
//

import SwiftUI

struct IngredientTag: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.bodyRegular)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.primaryGreen : Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.primaryGreen : Color.divider, lineWidth: 1)
                )
        }
    }
}

#Preview {
    VStack {
        IngredientTag(name: "milk", isSelected: false, action: {})
        IngredientTag(name: "milk", isSelected: true, action: {})
    }
    .padding()
    .background(Color.softBeige)
}
