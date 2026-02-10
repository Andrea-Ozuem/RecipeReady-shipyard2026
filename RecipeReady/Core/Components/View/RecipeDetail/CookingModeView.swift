//
//  CookingModeView.swift
//  RecipeReady
//
//  Created for UI Driven Development.
//

import SwiftUI

struct CookingModeView: View {
    let recipe: Recipe
    @Binding var isPresented: Bool
    
    @State private var currentStepIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .light)) // Thin, elegant X
                            .foregroundColor(.textPrimary)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Share action placeholder
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50) // Manual top padding to clear dynamic island/notch
                .background(Color.white) // Ensure background covers any content behind
                .zIndex(1) // Keep on top
                
                // MARK: - Content
                TabView(selection: $currentStepIndex) {
                    ForEach(Array(recipe.steps.sorted(by: { $0.order < $1.order }).enumerated()), id: \.offset) { index, step in
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(step.instruction)
                                .font(.pangram(.bold, size: 32)) // Large display font
                                .lineSpacing(8)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 30)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // MARK: - Bottom Bar
                VStack(spacing: 0) {
                    Divider()
                        .foregroundColor(Color.divider)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(Array(recipe.steps.sorted(by: { $0.order < $1.order }).enumerated()), id: \.offset) { index, _ in
                                    Button(action: {
                                        withAnimation {
                                            currentStepIndex = index
                                        }
                                    }) {
                                        ZStack {
                                            Rectangle()
                                                .fill(currentStepIndex == index ? Color.primaryGreen : Color.white)
                                            
                                            if index == recipe.steps.count - 1 {
                                                Image(systemName: "flag")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(currentStepIndex == index ? .white : .textPrimary)
                                            } else {
                                                Text(String(format: "%02d", index + 1))
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(currentStepIndex == index ? .white : .textPrimary)
                                            }
                                            
                                            // Vertical Divider
                                            if index < recipe.steps.count - 1 {
                                                HStack {
                                                    Spacer()
                                                    Rectangle()
                                                        .fill(Color.divider)
                                                        .frame(width: 1)
                                                        .frame(maxHeight: .infinity)
                                                }
                                            }
                                        }
                                        .frame(width: 80, height: 80) // Larger tap area
                                    }
                                    .id(index)
                                }
                            }
                        }
                        .onChange(of: currentStepIndex) { newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                    .frame(height: 80)
                    .background(Color.white)
                }
                .padding(.bottom, 0) // Pin to bottom
            }
        }
        .edgesIgnoringSafeArea(.all) // Take full screen
    }
}

#Preview {
    CookingModeView(
        recipe: Recipe(
            title: "Test",
            steps: [
                CookingStep(order: 1, instruction: "First, the meat gets ultra much taste from soy sauce and gochujang. Let it brown on high heat."),
                CookingStep(order: 2, instruction: "Add the vegetables and stir fry for 5 minutes."),
                CookingStep(order: 3, instruction: "Pour in the sauce and simmer."),
                CookingStep(order: 4, instruction: "Serve over rice.")
            ]
        ),
        isPresented: .constant(true)
    )
}
