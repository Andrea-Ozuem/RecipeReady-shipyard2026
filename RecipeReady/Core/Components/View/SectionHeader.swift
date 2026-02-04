//
//  SectionHeader.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.heading1)
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeader(title: "Ingredients")
        SectionHeader(title: "Instructions")
    }
    .padding()
}
