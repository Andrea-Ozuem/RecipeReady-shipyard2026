//
//  InstructionRow.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct InstructionRow: View {
    let step: CookingStep
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step Number Circle
            Text("\(step.order)")
                .font(.captionMeta) // or bodyBold for visibility
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.primaryGreen))
            
            // Instruction Text
            Text(step.instruction)
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true) // Wrap text
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    InstructionRow(step: CookingStep(order: 1, instruction: "Preheat the oven to 200°C. Make sure the rack is in the center."))
}
