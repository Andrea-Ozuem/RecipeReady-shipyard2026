//
//  ServingsStepper.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct ServingsStepper: View {
    @Binding var servings: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Minus Button
            Button(action: {
                if servings > 1 {
                    servings -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 32, height: 32)
            }
            .disabled(servings <= 1)
            
            // Current Servings Count
            Text("\(servings)")
                .font(.bodyBold)
                .foregroundColor(.textPrimary)
                .frame(minWidth: 24)
            
            // Plus Button
            Button(action: {
                servings += 1
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.softBeige)
        )
    }
}

#Preview {
    ServingsStepper(servings: .constant(4))
}
